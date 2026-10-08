class DictionaryHeader {
    constructor(subtitle = "Управляйте словами, которые вы изучаете", learned = 0, total = 0, onSearch = null) {
      this.subtitle = subtitle
      this.learned = learned
      this.total = total
      this.onSearch = onSearch
      this.item = this.createHeader()
    }
  
    createHeader() {
      const container = document.createElement("div")
      container.className = "text-center mb-4"
  
      const subtitleEl = document.createElement("p")
      subtitleEl.className = "text-muted mb-1"
      subtitleEl.textContent = this.subtitle
  
      const progressInfo = document.createElement("div")
      progressInfo.className = "fw-semibold text-secondary"
      progressInfo.textContent = `Изучено: ${this.learned} / ${this.total}`
  
      const progressBarWrap = document.createElement("div")
      progressBarWrap.className = "progress mt-2 mb-3"
      progressBarWrap.style.height = "6px"
  
      const progressBar = document.createElement("div")
      progressBar.className = "progress-bar bg-success"
      const percent = this.total > 0 ? (this.learned / this.total) * 100 : 0
      progressBar.style.width = `${percent}%`
      progressBarWrap.appendChild(progressBar)
  
      // Поиск
      const searchWrapper = document.createElement("div")
      searchWrapper.className = "mt-3 mb-2"
      const searchInput = document.createElement("input")
      searchInput.type = "text"
      searchInput.className = "form-control"
      searchInput.placeholder = "Поиск слова..."
      searchInput.addEventListener("input", (e) => {
        if (this.onSearch) this.onSearch(e.target.value)
      })
      searchWrapper.appendChild(searchInput)
  
      container.append(subtitleEl, progressInfo, progressBarWrap, searchWrapper)
      return container
    }
  }
  
  export default DictionaryHeader
  