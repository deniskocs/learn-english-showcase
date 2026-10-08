// LightButton.js
import { addButtonBehavior } from "./buttonBehavior.js"

export default function LightButton(text, onClick) {
    const button = document.createElement("button")
    button.className = "btn btn-outline-secondary btn-sm"
    button.textContent = text
    button.onclick = onClick
    return addButtonBehavior(button, text)
}

