import { track } from "../Analytics.js";

const State = {
  loading: () => ({ type: 'loading' }),
  error: (errorCode) => ({ type: 'error', errorCode }),
  data: (definitions, totalPages) => ({ type: 'data', definitions, totalPages })
}

class ActiveWordsModel {
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
        endpoint: "activeWords",
        params: `from=${(this.currentPage - 1) * this.pageSize}&to=${this.currentPage * this.pageSize}`,
        method: "GET"
      }
  
      this.networkService.send(request, (data) => {
        const definitions = data.definitions.map(d => ({ 
          word: d.word, 
          id: d.meaningId, 
          translation: d.translation, 
          progress: d.progress,
          nextReview: d.nextReview
        }))
        this.state = State.data(definitions, data.pagesCount)
        if (this.view && this.view.reload) this.view.reload()
        track("active_words_viewed", { page_index: this.currentPage } )
      }, (errorCode) => {
        this.state = State.error(errorCode)
        if (this.view && this.view.reload) this.view.reload()
      })
    }
  
    goNext() {
      if (this.state.type === 'data' && this.currentPage < this.state.totalPages) {
        track("pagination_clicked", { tab: "active", page_number: this.currentPage, page_size: this.pageSize, direction: "next" })
        this.currentPage++
        this.loadData()
        if (this.view && this.view.reload) this.view.reload()
      }
    }
  
    goPrior() {
      if (this.currentPage > 1) {
        track("pagination_clicked", { tab: "active", page_number: this.currentPage, page_size: this.pageSize, direction: "prev" })
        this.currentPage--
        this.loadData()
        if (this.view && this.view.reload) this.view.reload()
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
      track("word_marked_known", { word_id: word, sense_id: id, source_tab: "active" })
    }

    repeatDefinition(word, id, button) {
      this.networkService.repeatDefinition(
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
      track("repeat_definition", { word_id: word, sense_id: id, source_tab: "active"})
    }
  }
  
  export default ActiveWordsModel
  export { State }
  