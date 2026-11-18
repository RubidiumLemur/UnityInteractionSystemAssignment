using UnityEngine;
using TMPro;

public class StatusUI : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI statusText;

    public void ShowDoorOpened()
    {
        statusText.text = "Door has been opened";
    }
}
