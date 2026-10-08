class AnalyzerHeader {
    constructor(subtitle = "Анализируйте тексты, чтобы учить слова в контексте") {
      this.subtitle = subtitle
      this.item = this.createHeader()
    }
  
    createHeader() {
      const container = document.createElement("div")
      container.className = "text-center mb-4"
  
      const subtitleEl = document.createElement("p")
      subtitleEl.className = "text-muted mb-1"
      subtitleEl.textContent = this.subtitle
  
      container.append(subtitleEl)
      return container
    }
  }
  
  export default AnalyzerHeader
  