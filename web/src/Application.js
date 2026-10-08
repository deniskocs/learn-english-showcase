import Analyzer from "./analyzer/Analyzer.js"
import NetworkService from "./NetworkService.js"
import DictionaryView from "./dictionary/DictionaryView.js"
import DictionaryModel from "./dictionary/DictionaryModel.js"
import WelcomeView from "./WelcomeView.js"
import HomeView from "./HomeView.js"
import NavigationMenu from "./NavigationMenu.js"
import { setUserId, track, clearUserId } from './Analytics.js'
import './css/styles.css'

class Application {  
    constructor() {
        const savedToken = localStorage.getItem("auth_token")
        this.authentication = {
            "token": savedToken || null
        }
        this.networkService = new NetworkService(this.authentication, () => {
            this.authentication.token = null
            localStorage.removeItem("auth_token")
            this.render()
        })        
        
        if (window.google && google.accounts && google.accounts.id) {
            google.accounts.id.initialize({
                client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
                callback: (response) => {
                    console.log("ID Token:", response.credential)
                    this.tokenReceived(response.credential)
                }
            })
        }

        this.welcome = new WelcomeView(() => {
            this.loginButtonTapped()
        },)
        document.querySelector("#container").appendChild(this.welcome)
    }
    
    loginButtonTapped() {
        track('auth_started', { provider: 'google' });
        if (window.google && google.accounts && google.accounts.id) {
            google.accounts.id.prompt() // откроет стандартное окно входа Google
        } else {
            console.error("Google Identity Services не инициализированы")
        }
    }

    setRoot(view) {
        document.querySelector("#container").innerHTML = ""
        document.querySelector("#container").appendChild(view)
    }
    
    showDictionary() {    
        track('nav_clicked', { target: 'dictionary' })
        const model = new DictionaryModel(this.networkService)
        const view = new DictionaryView(model)
        this.setRoot(view)
        model.loadData()
        track('dictionary_viewed', { tab: 'new' })
    }
    
    showAnalyzer() {    
        track('nav_clicked', { target: 'analyzer' })
        const analyzerComponent = new Analyzer(this.networkService)
        this.setRoot(analyzerComponent)
        track('analyzer_viewed', { tab: 'text' })
    }

    tokenReceived(idToken) {
        this.networkService.authenticateWithGoogle(idToken, (response) => {
            console.log("Server response:", response)

            this.authentication.token = response.token
            localStorage.setItem("auth_token", response.token)
            setUserId(response.token)
            track('auth_completed', { provider: 'google', success: true });
            this.render()
        })
    }

    render() {
        const menuContainer = document.querySelector("#menuContainer")
        menuContainer.innerHTML = ""
      
        this.menu = new NavigationMenu(
            () => this.showDictionary(),
            () => this.showAnalyzer(),
            () => {
              this.authentication.token = null
              localStorage.removeItem("auth_token")
              this.render()
              track('auth_signed_out', { method: 'menu' })
              clearUserId();
            },
            this.authentication
        )
        menuContainer.appendChild(this.menu)
    
        if (this.authentication.token == null) {
            this.welcome = new WelcomeView(() => this.loginButtonTapped())
            this.setRoot(this.welcome);
            track('page_viewed', { path: '/', unauthenticated: true })
            track('cta_viewed', { cta: 'google_sign_in', location: 'welcome' })
        } else {
            this.home = new HomeView(
                () => this.showDictionary(),
                () => this.showAnalyzer()
            )
            this.setRoot(this.home);
            track('home_viewed', { unauthenticated: true })
        }
    }
}

let app;

function start() {
    app = new Application()
    app.render()
}

window.onload = function () {
    start()
};

export default Application
