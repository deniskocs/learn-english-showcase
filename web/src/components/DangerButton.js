import { addButtonBehavior } from "./buttonBehavior.js"

export default function DangerButton(text, onClick) {
    const button = document.createElement("button")
    button.className = "btn btn-outline-danger btn-sm"
    button.textContent = text
    button.onclick = onClick
    return addButtonBehavior(button, text)
}