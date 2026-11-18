using UnityEngine;
using TMPro;

public class FPSUI : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI fpsText;
    private float updateTimer;
    private int frames;

    private void Update()
    {
        frames++;
        updateTimer += Time.unscaledDeltaTime;
        if (updateTimer < 1f) return;
        fpsText.text = $"FPS: {Mathf.RoundToInt(frames / updateTimer)}";
        frames = 0;
        updateTimer = 0f;
    }
}
