import PrimaryButton from "../components/PrimaryButton.js"
import SecondaryButton from "../components/SecondaryButton.js"
import LightButton from "../components/LightButton.js"
import DangerButton from "../components/DangerButton.js"

export default function WordContextRow(item) {
    const row = document.createElement("tr")
    row.className = "word-row"

    const wordCell = document.createElement("td")
    wordCell.className = "align-middle"
    const wordSpan = document.createElement("div")
    wordSpan.className = "fw-semibold"
    wordSpan.textContent = item.word.word

    const meanings = item.word.meanings || []
    if (meanings.length > 0) {
      const translation = document.createElement("div")
      translation.textContent = meanings.length === 1
        ? meanings[0].translation
        : "<несколько значений>"
      translation.className = "text-secondary small mt-1"
      wordCell.append(wordSpan, translation)
    } else {
      wordCell.appendChild(wordSpan)
    }
    row.append(wordCell)

    const contextCell = document.createElement("td")
    if (item.word.context) {
        const div = document.createElement("div")
        div.innerHTML = String(item.word.context)
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
    if (item.light != null) {
        buttons.append(LightButton(item.light.name, () => item.light.onPress(item)))
    }
    if (item.delete != null) {
        buttons.append(DangerButton(item.delete.name, () => item.delete.onPress(item)))
    }

    const actionsCell = document.createElement("td")
    actionsCell.className = "text-end align-middle"
    actionsCell.append(buttons)
    row.append(actionsCell)

    return row
}
