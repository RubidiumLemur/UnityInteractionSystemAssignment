Shader "Graybox/World Space Tiling"
{
    Properties
    {
        [MainTexture] _BaseMap ("Texture (set Wrap Mode to Repeat)", 2D) = "white" {}
        [MainColor] _BaseColor ("Tint", Color) = (1, 1, 1, 1)
        _Tiling ("Tiles per World Unit", Float) = 1
        _BlendSharpness ("Projection Blend Sharpness", Range(1, 16)) = 4
        _Specular ("Specular", Range(0, 1)) = 0.25
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #define _SPECULAR_SETUP 1
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _Tiling;
                half _BlendSharpness;
                half _Specular;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 2);
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS, output.vertexSH);
                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half3 normalWS = normalize(input.normalWS);
                half3 blend = pow(abs(normalWS), _BlendSharpness);
                blend /= max(blend.x + blend.y + blend.z, 0.0001h);

                float3 position = input.positionWS * _Tiling;
                half4 xProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.zy);
                half4 yProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.xz);
                half4 zProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.xy);
                half4 albedo = (xProjection * blend.x + yProjection * blend.y + zProjection * blend.z) * _BaseColor;

                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, normalWS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

                SurfaceData surface = (SurfaceData)0;
                surface.albedo = albedo.rgb;
                surface.specular = _Specular.xxx;
                surface.occlusion = 1.0h;
                surface.smoothness = 0.5h;
                surface.alpha = albedo.a;
                return UniversalFragmentPBR(inputData, surface);
            }
            ENDHLSL
        }

        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }
            Cull Off

            HLSLPROGRAM
            #pragma vertex MetaVertex
            #pragma fragment WorldSpaceMetaFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _Tiling;
                half _BlendSharpness;
                half _Specular;
            CBUFFER_END

            struct MetaAttributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 staticLightmapUV : TEXCOORD1;
                float2 dynamicLightmapUV : TEXCOORD2;
            };

            struct MetaVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
            };

            MetaVaryings MetaVertex(MetaAttributes input)
            {
                MetaVaryings output;
                output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.staticLightmapUV, input.dynamicLightmapUV);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 WorldSpaceMetaFragment(MetaVaryings input) : SV_Target
            {
                half3 normalWS = normalize(input.normalWS);
                half3 blend = pow(abs(normalWS), _BlendSharpness);
                blend /= max(blend.x + blend.y + blend.z, 0.0001h);

                float3 position = input.positionWS * _Tiling;
                half4 xProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.zy);
                half4 yProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.xz);
                half4 zProjection = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, position.xy);
                half4 albedo = (xProjection * blend.x + yProjection * blend.y + zProjection * blend.z) * _BaseColor;

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = albedo.rgb;
                return UnityMetaFragment(metaInput);
            }
            ENDHLSL
        }
    }
}
