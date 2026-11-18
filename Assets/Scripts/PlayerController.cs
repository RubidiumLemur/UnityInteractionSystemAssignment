using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private Transform playerCamera;
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float lookSensitivity = 0.08f;
    [SerializeField] private float jumpHeight = 1.5f;

    private CharacterController controller;
    private float verticalSpeed;
    private float cameraPitch;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    private void Update()
    {
        Keyboard keyboard = Keyboard.current;
        if (keyboard == null) return;

        if (Mouse.current != null)
        {
            Vector2 look = Mouse.current.delta.ReadValue() * lookSensitivity;
            transform.Rotate(Vector3.up, look.x);
            cameraPitch = Mathf.Clamp(cameraPitch - look.y, -85f, 85f);
            playerCamera.localRotation = Quaternion.Euler(cameraPitch, 0f, 0f);
        }

        Vector2 input = Vector2.zero;
        if (keyboard.wKey.isPressed) input.y++;
        if (keyboard.sKey.isPressed) input.y--;
        if (keyboard.dKey.isPressed) input.x++;
        if (keyboard.aKey.isPressed) input.x--;

        if (controller.isGrounded)
        {
            if (verticalSpeed < 0f) verticalSpeed = -2f;
            if (keyboard.spaceKey.wasPressedThisFrame)
                verticalSpeed = Mathf.Sqrt(jumpHeight * -2f * Physics.gravity.y);
        }
        verticalSpeed += Physics.gravity.y * Time.deltaTime;
        Vector3 movement = (transform.right * input.x + transform.forward * input.y).normalized * moveSpeed;
        movement.y = verticalSpeed;
        controller.Move(movement * Time.deltaTime);
    }
}
