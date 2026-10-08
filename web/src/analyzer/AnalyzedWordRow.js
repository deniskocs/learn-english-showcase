import PrimaryButton from "../components/PrimaryButton.js"
import SecondaryButton from "../components/SecondaryButton.js"

export default function AnalyzedWordRow(item) {
    const word = item.word || item
    const row = document.createElement("tr")
    row.className = "word-row"

    const wordCell = document.createElement("td")
    wordCell.className = "align-middle"

    const english = document.createElement("div")
    english.className = "fw-semibold"
    english.textContent = word.english || ""

    const russian = document.createElement("div")
    russian.className = "text-secondary small mt-1"
    russian.textContent = word.russian || ""

    wordCell.append(english, russian)
    row.append(wordCell)

    const contextCell = document.createElement("td")
    const sentences = Array.isArray(word.sentences) ? word.sentences : []
    for (const sentence of sentences) {
        if (sentence == null || sentence === "") {
            continue
        }
        const div = document.createElement("div")
        div.innerHTML = String(sentence)
        div.className = "context-sentence small"
        contextCell.appendChild(div)
    }
    row.append(contextCell)

    const buttons = document.createElement("div")
    buttons.className = "d-flex justify-content-end gap-2 flex-nowrap"
    if (item.primary != null) {
        buttons.append(PrimaryButton(item.primary.name, () => item.primary.onPress(item)))
    }
    if (item.secondary != null) {
        buttons.append(SecondaryButton(item.secondary.name, () => item.secondary.onPress(item)))
    }

    const actionsCell = document.createElement("td")
    actionsCell.className = "text-end align-middle"
    actionsCell.append(buttons)
    row.append(actionsCell)

    return row
}
