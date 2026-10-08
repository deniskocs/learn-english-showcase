class Pager {
    constructor(currentPage = 1, totalPages = 1, onPrev = null, onNext = null) {
      this.currentPage = currentPage
      this.totalPages = totalPages
      this.onPrev = onPrev
      this.onNext = onNext
      this.item = this.createPager()
    }
  
    createPager() {
      const container = document.createElement("div")
      container.className = "d-flex justify-content-between align-items-center mt-3"
  
      // Кнопка "Назад"
      const prevButton = document.createElement("button")
      prevButton.className = "btn btn-outline-primary btn-sm"
      prevButton.innerHTML = "&larr; Назад"
      prevButton.disabled = this.currentPage <= 1
      prevButton.addEventListener("click", () => {
        if (this.onPrev && this.currentPage > 1) this.onPrev()
      })
  
      // Информация о странице
      const pageInfo = document.createElement("span")
      pageInfo.className = "text-muted small"
      pageInfo.textContent = `Страница ${this.currentPage} из ${this.totalPages}`
  
      // Кнопка "Далее"
      const nextButton = document.createElement("button")
      nextButton.className = "btn btn-outline-primary btn-sm"
      nextButton.innerHTML = "Далее &rarr;"
      nextButton.disabled = this.currentPage >= this.totalPages
      nextButton.addEventListener("click", () => {
        if (this.onNext && this.currentPage < this.totalPages) this.onNext()
      })
  
      container.append(prevButton, pageInfo, nextButton)
      return container
    }
  
    update(currentPage, totalPages) {
      this.currentPage = currentPage
      this.totalPages = totalPages
      this.item.querySelector("span").textContent = `Страница ${this.currentPage} из ${this.totalPages}`
      this.item.querySelectorAll("button")[0].disabled = this.currentPage <= 1
      this.item.querySelectorAll("button")[1].disabled = this.currentPage >= this.totalPages
    }
  }
  
  export default Pager
  