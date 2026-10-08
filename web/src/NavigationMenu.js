class NavigationMenu {
    constructor(onViewWords, onTextAnalysis, onLogout, authentication) {
      this.onViewWords = onViewWords
      this.onTextAnalysis = onTextAnalysis
      this.onLogout = onLogout
      this.authentication = authentication
  
      this.item = this.createMenu()
      return this.item
    }
  
    createMenu() {
        const nav = document.createElement("nav")
        nav.className = "navbar navbar-light bg-white shadow-sm fixed-top"
      
        // если пользователь не авторизован — показываем старый дефолтный хедер
        if (!this.authentication.token) {
          const container = document.createElement("div")
          container.className = "container"
      
          const brand = document.createElement("a")
          brand.className = "navbar-brand fw-bold text-primary"
          brand.href = "#"
          brand.textContent = "Learn English"
      
          container.appendChild(brand)
          nav.appendChild(container)
          return nav
        }
      
        // если авторизован — показываем меню
        const container = document.createElement("div")
        container.className = "container d-flex justify-content-between align-items-center"
      
        const brand = document.createElement("a")
        brand.className = "navbar-brand fw-bold text-primary"
        brand.href = "#"
        brand.textContent = "Learn English"
      
        const menu = document.createElement("ul")
        menu.className = "nav"
      
        const viewWords = this.createMenuItem("Словарь", this.onViewWords)
        const analyzeText = this.createMenuItem("Разбор текста", this.onTextAnalysis)
        const logout = this.createMenuItem("Выход", this.onLogout)
      
        menu.append(viewWords, analyzeText, logout)
        container.append(brand, menu)
        nav.appendChild(container)
      
        return nav
    }
  
    createMenuItem(title, onClick) {
      const li = document.createElement("li")
      li.className = "nav-item"
      const a = document.createElement("a")
      a.className = "nav-link"
      a.href = "#"
      a.textContent = title
      a.onclick = (e) => {
        e.preventDefault()
        document.querySelectorAll(".nav-link").forEach(link => link.classList.remove("active"))
        a.classList.add("active")
        onClick()
      }
      li.appendChild(a)
      return li
    }
  }
  
  export default NavigationMenu
  