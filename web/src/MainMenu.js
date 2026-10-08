class MainMenu {

    constructor(vocabularyTapped, analyzerTapped, tokenReceived, logoutTapped, authentication) {
        this.vocabularyTapped = vocabularyTapped
        this.analyzerTapped = analyzerTapped
        this.tokenReceived = tokenReceived
        this.logoutTapped = logoutTapped
        this.authentication = authentication

        this.item = document.createElement("ul")
        this.item.classList.add("mainMenu")

        if (window.google && google.accounts && google.accounts.id) {
            google.accounts.id.initialize({
                client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
                callback: (response) => {
                    console.log("ID Token:", response.credential)
                    this.tokenReceived(response.credential)
                }
            })
        }

        this.render()
    }


    createMenuItem(text, onClick) {
        let link = document.createElement("li")
        let href = document.createElement("a")
        href.innerText =text
        link.append(href)

        href.addEventListener("click", onClick)

        return link
    }

    signOutTapped() {
        this.logoutTapped()
    }

    render() {
        this.item.innerHTML = ""
        if (this.authentication.token == null) {

            // Кнопка Google Sign-In как элемент меню
            const googleItem = document.createElement("li")
            const googleButton = document.createElement("div")
            googleItem.append(googleButton)
            this.item.append(googleItem)

            // отрисовка стандартной кнопки Google
            if (window.google && google.accounts && google.accounts.id) {
                google.accounts.id.renderButton(
                    googleButton,
                    {
                        type: "standard",
                        shape: "rectangular",
                        theme: "outline",
                        text: "signin",
                        size: "medium"
                    }
                )
            }
        } else {
            this.vocabularyLink = this.createMenuItem("Vocabulary builder", this.vocabularyTapped)
            this.item.append(this.vocabularyLink)
            this.textAnalyzer = this.createMenuItem("Text analyzer", this.analyzerTapped)
            this.item.append(this.textAnalyzer)
            this.signOut = this.createMenuItem("Sign Out", () => {
                this.signOutTapped()
            })
            this.item.append(this.signOut)
        }
    }
}

export default MainMenu;