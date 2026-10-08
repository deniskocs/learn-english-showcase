class WelcomeView {
    constructor(onLoginClicked) {
        this.onLoginClicked = onLoginClicked
        this.item = this.createView()
        return this.item
    }
  
    createView() {
        const container = document.createElement("div")
        container.className = "container d-flex flex-column align-items-center justify-content-center text-center py-5"
        container.style.maxWidth = "600px"
  
        const title = document.createElement("h1")
        title.className = "fw-bold mb-3"
        title.textContent = "Изучай английский эффективно"
  
        const subtitle = document.createElement("p")
        subtitle.className = "text-muted mb-4"
        subtitle.textContent = "Отмечай слова, которые ты уже знаешь, анализируй тексты и концентрируйся только на новых словах."
  
        const buttonWrapper = document.createElement("div")
        buttonWrapper.className = "d-grid gap-2 col-8 mx-auto"
  
        // Кнопка Google Sign-In как элемент меню
        const googleButton = document.createElement("div")

        // отрисовка стандартной кнопки Google
        if (window.google && google.accounts && google.accounts.id) {
            google.accounts.id.renderButton(
                googleButton,
                {
                    type: "standard",
                    shape: "rectangular",
                    theme: "outline",
                    text: "signin",
                    size: "large"
                }
            )
        }
  
        buttonWrapper.appendChild(googleButton)
  
        const footerText = document.createElement("p")
        footerText.className = "text-muted mt-4 small"
        footerText.textContent = "После входа ты сможешь отмечать известные слова и анализировать тексты."
  
        container.append(title, subtitle, buttonWrapper, footerText)
        return container
    }
}
  
export default WelcomeView
  