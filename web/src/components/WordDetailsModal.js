import DictionaryRow from "../dictionary/DictionaryRow.js"
import { track } from "../Analytics.js"

class WordDetailsModal {
  constructor(model) {
    this.model = model
    this.model.view = this

    this.item = this.createModal()
    this.subscribeToOnClose()
    return this.item
  }

  createModal() {
    const modal = document.createElement("div")
    modal.className = "modal fade"
    modal.id = "wordModal"
    modal.tabIndex = -1
    modal.setAttribute("aria-hidden", "true")

    modal.innerHTML = `
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="wordModalLabel">Значения</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body" id="wordModalBody">
          </div>
        </div>
      </div>
    `

    this.table = document.createElement("table")
    this.table.className = "table table-hover align-middle mb-0"
    modal.querySelector("#wordModalBody").appendChild(this.table)

    this.render()

    modal.querySelector("#wordModalLabel").textContent = this.model.word.word
    return modal
  }

  subscribeToOnClose() {
    this.item.addEventListener("hide.bs.modal", () => {
      if (this.model.definitions.length < 2) {
        this.model.reload()
      } else {
        track("modal_closed", { modal: "word_details", reason: "manual" })
      }
    })
  }

  render() {
    this.table.innerHTML = ""
  
    const tbody = document.createElement("tbody")
      
    this.model.definitions.forEach((word, index) => {
      const row = DictionaryRow(this.model.rowModel(index, word))
      tbody.appendChild(row)
    })

    this.table.appendChild(tbody)
  }

  close() {
    const modal = bootstrap.Modal.getInstance(this.item) || new bootstrap.Modal(this.item)
    modal.hide()
  }

}

export default WordDetailsModal
