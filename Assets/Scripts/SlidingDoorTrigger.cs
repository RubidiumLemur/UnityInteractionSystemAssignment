using UnityEngine;

public class SlidingDoorTrigger : MonoBehaviour
{
    [SerializeField] private SlidingDoor slidingDoor;
    [SerializeField] private StatusUI statusUI;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip openSound;

    private bool triggered;

    private void OnTriggerEnter(Collider other)
    {
        if (triggered || !other.CompareTag("Player")) return;
        triggered = true;
        slidingDoor.Open();
        statusUI.ShowDoorOpened();
        if (openSound != null) audioSource.PlayOneShot(openSound);
    }
}
