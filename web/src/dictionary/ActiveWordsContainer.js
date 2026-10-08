import Pager from "../components/Pager.js"
import DictionaryRow from "./DictionaryRow.js"
import Loader from "../components/Loader.js"
import EmptyBody from "../components/EmptyBody.js"
import ErrorPlaceholder from "../components/ErrorPlaceholder.js"
import { State } from "./ActiveWordsModel.js"

class ActiveWordsContainer {
  constructor(model) {
    this.model = model
    this.model.view = this
    this.item = document.createElement("div")
    this.item.className = "active-words-container mt-3"
    this.model.loadData()
    this.render()
  }

  render() {
    this.item.innerHTML = ""
  
    if (this.model.state.type === 'loading') {
      this.item.appendChild(Loader())
    } else if (this.model.state.type === 'error') {
      this.item.appendChild(ErrorPlaceholder(() => this.model.loadData()))
    } else if (this.model.state.type === 'data') {
      const table = document.createElement("table")
      table.className = "table table-hover align-middle mb-0"

      if (this.model.state.definitions.length === 0) {
        table.appendChild(EmptyBody("Нет слов в обучении"))
      } else {
        const tbody = document.createElement("tbody")
        
        this.model.state.definitions.forEach(definition => {
          const row = DictionaryRow({
            word: definition,
            primary: {
              name: "Завершить",
              onPress: (rowItem, button) => this.markDefinitionAsTrained(rowItem.word.word, rowItem.word.id, button) 
            },
            secondary: {
              name: "Повторить",
              onPress: (rowItem, button) => this.repeatDefinition(rowItem.word.word, rowItem.word.id, button) 
            }
          })
          tbody.appendChild(row)
        })
        table.appendChild(tbody)
      }
  
      this.item.append(table)
    }
  
    if (this.model.state.type === 'data' && this.model.state.totalPages != null) {
      const pager = new Pager(
        this.model.currentPage,
        this.model.state.totalPages,
        () => { this.model.goPrior() },
        () => { this.model.goNext() }
      )
      this.item.append(pager.item)
    }
  }

  markDefinitionAsTrained(word, id, button) {
    console.log(word, id)
    button.displayLoading()
    this.model.markDefinitionAsTrained(word, id, button)
  }

  repeatDefinition(word, id, button) {
    console.log(word, id)
    button.displayLoading()
    this.model.repeatDefinition(word, id, button)
  }

  reload() {
    this.render()
  }
}

export default ActiveWordsContainer
