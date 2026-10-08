export default function CardContainer(content) {
    const div = document.createElement("div")
    div.className = "tab-pane fade show active"
    div.id = "textAnalyze"
    div.role = "tabpanel"

    const card = document.createElement("div")
    card.className = "card shadow-sm mb-4"

    const cardBody = document.createElement("div")
    cardBody.className = "card-body"

    const inner = document.createElement("div")
    inner.className = "mb-3"

    if (content instanceof HTMLElement) inner.appendChild(content)
    else inner.innerHTML = content

    cardBody.appendChild(inner)
    card.appendChild(cardBody)
    div.appendChild(card)
    return div
}