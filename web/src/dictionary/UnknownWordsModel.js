import { track } from "../Analytics.js";

const State = {
  loading: () => ({ type: 'loading' }),
  error: (errorCode) => ({ type: 'error', errorCode }),
  data: (words, totalPages) => ({ type: 'data', words, totalPages })
}

class UnknownWordsModel {
    constructor(networkService) {
        this.networkService = networkService
        this.view = null      

        this.pageSize = 8
        this.currentPage = 1
        this.state = State.loading()
        this.words = []
    }
  
    loadData() {
        this.state = State.loading()
        if (this.view && this.view.reload) this.view.reload()

        const request = {
            endpoint: "unknownWords",
            params: `from=${(this.currentPage - 1) * this.pageSize}&to=${this.currentPage * this.pageSize}`,
            method: "GET",
        }
  
        this.networkService.send(request, (data) => {
            const words = data.words.map(w => ({ word: w.word, translation: w.definitions.length == 1 ? w.definitions[0].translation : "<несколько значений>", progress: null, definitions: w.definitions }))
            this.state = State.data(words, data.pagesCount)
            if (this.view && this.view.reload) this.view.reload()
            track("new_words_viewed", { page_index: this.currentPage } )
        }, (errorCode) => {
            this.state = State.error(errorCode)
            if (this.view && this.view.reload) this.view.reload()
        })
    }
  
    goNext() {
      if (this.state.type === 'data' && this.currentPage < this.state.totalPages) {
        track("pagination_clicked", { tab: "unknown", page_number: this.currentPage, page_size: this.pageSize, direction: "next" })
        this.currentPage++
        this.loadData()
      }
    }
  
    goPrior() {
      if (this.currentPage > 1) {
        track("pagination_clicked", { tab: "unknown", page_number: this.currentPage, page_size: this.pageSize, direction: "prev" })
        this.currentPage--
        this.loadData()
      }
    }
  
    markDefinitionAsTrained(word, id, button) {
      this.networkService.markDefinitionAsTrained(
        word, 
        id, 
        () => {
          button.reset()
          this.loadData()
        },
        () => {
          button.displayError()
        }
      )
      track("word_marked_known", { word_id: word, sense_id: id, source_tab: "new" })
    }

    trainDefinition(word, id, button) {
      this.networkService.trainDefinition(
        word, 
        id, 
        () => {
          button.reset()
          this.loadData()
        },
        () => {
          button.displayError()
        }
      )
      track("word_added_to_learning", { word_id: word, sense_id: id, source_tab: "new" })
    }

    removeDefinition(word, id, button) {  
      this.networkService.removeDefinition(
        word, 
        id, 
        () => {
          button.reset()
          this.loadData()
        },
        () => {
          button.displayError()
        }
      )
      track("word_deleted", { word_id: word, source_tab: "new" })
    }
  }
  
  export default UnknownWordsModel
  export { State }
  