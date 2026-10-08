class SpeechAnalysisCard {
  constructor(data, onDelete = null, onClick = null) {
    this.data = data
    this.onDelete = onDelete
    this.onClick = onClick
    this.isHighlighted = false
    this.item = this.createCard()
  }

  createCard() {
    const card = document.createElement("div")
    card.className = "analysis-card"
    card.style.cssText = `
      position: relative;
      background: #fff;
      border: 1px solid #dee2e6;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 16px;
      transition: box-shadow 0.2s ease, background-color 0.2s ease;
    `
    
    // Если статус "ready", делаем карточку кликабельной
    if (this.data.status === "ready" && this.onClick) {
      card.style.cursor = "pointer"
      card.addEventListener("click", (e) => {
        // Не срабатывает при клике на крестик удаления
        if (e.target.closest(".delete-icon")) {
          return
        }
        this.toggleHighlight()
        this.onClick(this.data, this.isHighlighted)
      })
    }
    
    card.addEventListener("mouseenter", () => {
      if (!this.isHighlighted) {
        card.style.boxShadow = "0 0 8px rgba(0,0,0,0.08)"
      }
    })
    card.addEventListener("mouseleave", () => {
      if (!this.isHighlighted) {
        card.style.boxShadow = "none"
      }
    })

    // Крестик для удаления
    if (this.onDelete) {
      const deleteIcon = document.createElement("span")
      deleteIcon.className = "delete-icon"
      deleteIcon.title = "Удалить"
      deleteIcon.innerHTML = "&times;"
      deleteIcon.style.cssText = `
        position: absolute;
        top: 16px;
        right: 16px;
        color: #dc3545;
        font-size: 1.4rem;
        cursor: pointer;
        line-height: 1;
        font-weight: 300;
        transition: color 0.2s ease;
      `
      deleteIcon.addEventListener("mouseenter", () => {
        deleteIcon.style.color = "#b02a37"
      })
      deleteIcon.addEventListener("mouseleave", () => {
        deleteIcon.style.color = "#dc3545"
      })
      deleteIcon.addEventListener("click", () => {
        if (this.onDelete) {
          this.onDelete(this.data)
        }
      })
      card.appendChild(deleteIcon)
    }

    // Заголовок
    const title = document.createElement("div")
    title.className = "analysis-title"
    title.style.cssText = `
      font-weight: 600;
      font-size: 1.1rem;
      margin-bottom: 8px;
      color: #212529;
      padding-right: ${this.onDelete ? "30px" : "0"};
    `
    title.textContent = this.data.title || "Анализ записи"
    card.appendChild(title)

    // Описание
    const description = document.createElement("div")
    description.className = "analysis-description"
    description.style.cssText = `
      font-size: 0.95rem;
      color: #6c757d;
      line-height: 1.5;
    `
    description.textContent = this.data.description || ""
    card.appendChild(description)

    return card
  }

  toggleHighlight() {
    this.isHighlighted = !this.isHighlighted
    if (this.isHighlighted) {
      this.item.style.backgroundColor = "#e7f3ff"
      this.item.style.borderColor = "#0d6efd"
      this.item.style.boxShadow = "0 0 12px rgba(13, 110, 253, 0.2)"
    } else {
      this.item.style.backgroundColor = "#fff"
      this.item.style.borderColor = "#dee2e6"
      this.item.style.boxShadow = "none"
    }
  }

  removeHighlight() {
    if (this.isHighlighted) {
      this.toggleHighlight()
    }
  }

  update(data) {
    this.data = data
    const title = this.item.querySelector(".analysis-title")
    const description = this.item.querySelector(".analysis-description")
    if (title) title.textContent = data.title || "Анализ записи"
    if (description) description.textContent = data.description || ""
  }
}

export default SpeechAnalysisCard

