// SecondaryButton.js
import { addButtonBehavior } from "./buttonBehavior.js"

export default function SecondaryButton(text, onClick) {
    const button = document.createElement("button")
    button.className = "btn btn-outline-primary btn-sm"
    button.textContent = text
    button.onclick = onClick
    return addButtonBehavior(button, text)
}