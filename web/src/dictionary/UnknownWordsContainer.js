import Pager from "../components/Pager.js"
import Loader from "../components/Loader.js"
import DictionaryRow from "./DictionaryRow.js"
import EmptyBody from "../components/EmptyBody.js"
import ErrorPlaceholder from "../components/ErrorPlaceholder.js"
import WordDetailsModal from "../components/WordDetailsModal.js"
import UnknownWordDetailsModalModel from "./UnknownWordDetailsModalModel.js"
import { track } from "../Analytics.js";

class UnknownWordsContainer {
    constructor(model) {
        this.model = model
        this.model.view = this

        this.item = document.createElement("div")
        this.item.className = "new-words-container mt-3"
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
            if (this.model.state.words.length === 0) {
                table.appendChild(EmptyBody("Нет слов для обучения"))
            } else {
                const tbody = document.createElement("tbody")

                this.model.state.words.forEach(item => {
                    if (item.definitions.length > 1) {
                        const row = DictionaryRow({
                            word: item,
                            light: {
                                name: "Варианты",
                                onPress: () => this.showDetails(item) 
                            }
                        })
                        tbody.appendChild(row)
                    } else {
                        const row = DictionaryRow({
                            word: item,
                            primary: {
                                name: "Знаю",
                                onPress: (rowItem, button) => this.markDefinitionAsTrained(rowItem.word.word, rowItem.word.definitions[0].meaningId, button) 
                            },
                            secondary: {
                                name: "Учить",
                                onPress: (rowItem, button) => this.trainDefinition(rowItem.word.word, rowItem.word.definitions[0].meaningId, button) 
                            },
                            delete: {
                                name: "Удалить",
                                onPress: (rowItem, button) => this.removeDefinition(rowItem.word.word, rowItem.word.definitions[0].meaningId, button) 
                            }  
                        })
                        tbody.appendChild(row)
                    }
                })

                table.appendChild(tbody)
            }
            this.item.append(table)
        }

        if (this.model.state.type === 'data' && this.model.state.totalPages != null) {
            const pager = new Pager(this.model.currentPage, this.model.state.totalPages, () => { this.model.goPrior() }, () => { this.model.goNext() } )
            this.item.append(pager.item)
        }
    }

    showDetails(word) {
        if (word.definitions.length > 1) {
            const modalModel = new UnknownWordDetailsModalModel(word, this.model.networkService, () => this.model.loadData())
            const modal = new WordDetailsModal(modalModel)
            document.body.appendChild(modal)
            const modalInstance = new bootstrap.Modal(modal)
            modalInstance.show()    
            track("word_details_opened", { word_id: word.word, senses_count: word.definitions.length })
        }
    }

    markDefinitionAsTrained(word, id, button) {
        console.log(word, id)
        button.displayLoading()
        this.model.markDefinitionAsTrained(word, id, button)
    }

    trainDefinition(word, id, button) {
        console.log(word, id)
        button.displayLoading()
        this.model.trainDefinition(word, id, button)
    }

    removeDefinition(word, id, button) {
        console.log(word, id)
        button.displayLoading()
        this.model.removeDefinition(word, id, button)
    }

    reload() {
        this.render()
    }
}

export default UnknownWordsContainer
