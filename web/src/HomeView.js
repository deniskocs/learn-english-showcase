class HomeView {
    constructor(onVocabularyClicked, onAnalyzerClicked, userName = "User") {
      this.onVocabularyClicked = onVocabularyClicked
      this.onAnalyzerClicked = onAnalyzerClicked
      this.userName = userName
      this.item = this.createView()
      return this.item
    }
  
    createView() {
      const container = document.createElement("div")
      container.className = "container d-flex flex-column align-items-center justify-content-center text-center py-5"
      container.style.maxWidth = "700px"
  
      const title = document.createElement("h1")
      title.className = "fw-bold mb-3"
      title.textContent = `Привет, ${this.userName}!`
  
      const subtitle = document.createElement("p")
      subtitle.className = "text-muted mb-4"
      subtitle.textContent = "Выберите, что хотите сделать:"
  
      const buttonWrapper = document.createElement("div")
      buttonWrapper.className = "d-flex flex-wrap gap-3 justify-content-center"
  
      const vocabButton = document.createElement("button")
      vocabButton.className = "btn btn-primary btn-lg px-4"
      vocabButton.textContent = "Словарь"
      vocabButton.onclick = this.onVocabularyClicked
  
      const analyzerButton = document.createElement("button")
      analyzerButton.className = "btn btn-outline-primary btn-lg px-4"
      analyzerButton.textContent = "Разбор текста"
      analyzerButton.onclick = this.onAnalyzerClicked
  
      buttonWrapper.append(vocabButton, analyzerButton)
  
      container.append(title, subtitle, buttonWrapper)
      return container
    }
  }
  
  export default HomeView