import PrimaryButton from "../components/PrimaryButton.js"
import SecondaryButton from "../components/SecondaryButton.js"
import LightButton from "../components/LightButton.js"
import DangerButton from "../components/DangerButton.js"
import Progress from "../components/Progress.js"

export default function DictionaryRow(item) {
    const row = document.createElement("tr")
    row.className = "word-row"
  

    const wordCell = document.createElement("td")
    wordCell.className = "fw-semibold align-middle"
  
    const wordText = document.createElement("div")
    wordText.textContent = item.word.word
    wordText.className = "fw-semibold"
  
    if (item.word.translation) {
      const translation = document.createElement("div")
      translation.textContent = item.word.translation
      translation.className = "text-secondary small mt-1"
      wordCell.append(wordText, translation)
    } else {
      wordCell.append(wordText)
    }
    row.append(wordCell)

    if (item.word.progress != null) {
        const progressCell = document.createElement("td")
        progressCell.style.width = "40%"
        progressCell.className = "align-middle"
        progressCell.appendChild(Progress(item.word.progress))
      
        if (item.word.nextReview != null) {
          const status = document.createElement("div")
          status.className = "small text-secondary mt-1"
          status.textContent = item.word.nextReview
          progressCell.appendChild(status)
        }

        row.append(progressCell)
    }
  
    const buttons = document.createElement("div")
    buttons.className = "d-flex justify-content-end gap-2 flex-nowrap"
    if (item.primary != null) {  
        const button = PrimaryButton(item.primary.name, () => item.primary.onPress(item, button))
        buttons.append(button)
    }

    if (item.secondary != null) {  
        const button = SecondaryButton(item.secondary.name, () => item.secondary.onPress(item, button))
        buttons.append(button)
    }

    if (item.light != null) {  
        const button = LightButton(item.light.name, () => item.light.onPress(item, button))
        buttons.append(button)
    }

    if (item.delete != null) {  
        const button = DangerButton(item.delete.name, () => item.delete.onPress(item, button))
        buttons.append(button)
    }

    const actionsCell = document.createElement("td")
    actionsCell.className = "text-end align-middle"
    actionsCell.append(buttons)
    row.append(actionsCell)

    return row
  }