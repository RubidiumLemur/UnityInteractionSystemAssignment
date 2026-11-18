using System.Collections;
using UnityEngine;

public class SlidingDoor : MonoBehaviour
{
    [SerializeField] private float openHeight = 3.2f;
    [SerializeField] private float slideSpeed = 2.5f;

    private Vector3 openPosition;
    private bool hasOpened;

    private void Awake()
    {
        openPosition = transform.position + Vector3.up * openHeight;
    }

    public void Open()
    {
        if (hasOpened) return;
        hasOpened = true;
        Collider doorCollider = GetComponent<Collider>();
        if (doorCollider != null) doorCollider.enabled = false;
        StartCoroutine(SlideUp());
    }

    private IEnumerator SlideUp()
    {
        while (transform.position != openPosition)
        {
            transform.position = Vector3.MoveTowards(transform.position, openPosition, slideSpeed * Time.deltaTime);
            yield return null;
        }
    }
}
