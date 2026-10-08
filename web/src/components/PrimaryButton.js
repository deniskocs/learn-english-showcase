// PrimaryButton.js
import { addButtonBehavior } from "./buttonBehavior.js"

export default function PrimaryButton(text, onClick) {
    const button = document.createElement("button")
    button.className = "btn btn-outline-success btn-sm"
    button.textContent = text
    button.onclick = onClick
    return addButtonBehavior(button, text)
}