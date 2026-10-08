import { track } from "../Analytics.js";

const State = {
  loading: () => ({ type: 'loading' }),
  error: (errorCode) => ({ type: 'error', errorCode }),
  data: (words, totalPages) => ({ type: 'data', words, totalPages })
}

class KnownWordsModel {
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
        endpoint: "knownWords",
        params: `from=${(this.currentPage - 1) * this.pageSize}&to=${this.currentPage * this.pageSize}`,
        method: "GET"
      }
  
      this.networkService.send(request, (data) => {
        const words = data.words.map(w => ({ word: w.word, translation: w.definitions.length == 1 ? w.definitions[0].translation : "<несколько значений>", progress: null, definitions: w.definitions }))
        this.state = State.data(words, data.pagesCount)
        if (this.view && this.view.reload) this.view.reload()
        track("known_words_viewed", { page_index: this.currentPage })
      }, (errorCode) => {
        this.state = State.error(errorCode)
        if (this.view && this.view.reload) this.view.reload()
      })
    }
  
    goNext() {
      if (this.state.type === 'data' && this.currentPage < this.state.totalPages) {
        track("pagination_clicked", { tab: "known", page_number: this.currentPage, page_size: this.pageSize, direction: "next" })
        this.currentPage++
        this.loadData()
        if (this.view && this.view.reload) this.view.reload()
      }
    }
  
    goPrior() {
      if (this.currentPage > 1) {
        track("pagination_clicked", { tab: "known", page_number: this.currentPage, page_size: this.pageSize, direction: "prev" })
        this.currentPage--
        this.loadData()
        if (this.view && this.view.reload) this.view.reload()
      }
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
      track("word_added_to_learning", { word_id: word, sense_id: id, source_tab: "known" })
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
      track("remove_definition", { word_id: word, sense_id: id, source_tab: "known"})
    }
  }
  
  export default KnownWordsModel
  export { State }
  