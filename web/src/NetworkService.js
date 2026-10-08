import { track } from './Analytics.js';

class NetworkService {
    domain = import.meta.env.VITE_API_BASE_URL

    constructor(authentication, onLogout = null) {
        this.authentication = authentication
        this.onLogout = onLogout
    }

    parseJwt(token) {
        var base64Url = token.split('.')[1];
        var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        var jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));

        return JSON.parse(jsonPayload);
    };

    send(request, onSuccess, onError) {
        if (request.simulate404) {
            // Срабатывает в 30% случаев
            if (Math.random() < 0.3) {
                // Задержка перед возвратом ошибки
                setTimeout(() => {
                    if (onError) {
                        onError(404)
                    }
                }, 500)
                return
            }
            // В остальных 70% случаев продолжаем выполнение запроса
        }
        
        if (request.method == "GET") {
            let url = `${this.domain}/${request.endpoint}?${request.params == undefined ? "" : request.params}`
            var httpRequest = new XMLHttpRequest();
            httpRequest.onreadystatechange = () => {
                if (httpRequest.readyState == 4) {
                    if (httpRequest.status == 200) {
                        onSuccess(JSON.parse(httpRequest.responseText));
                    } else if (httpRequest.status == 401) {
                        this.handleTokenError(httpRequest.responseText);
                    } else {
                        if (onError) {
                            onError(httpRequest.status)
                        }
                    }
                }
            }
            httpRequest.open( request.method, url, true )
            httpRequest.setRequestHeader("Authorization", this.authentication.token)
            httpRequest.send( null )
        } else if (request.method == "POST") {
            let url = `${this.domain}/${request.endpoint}${request.params ? `?${request.params}` : ""}`
            var httpRequest = new XMLHttpRequest()
            httpRequest.onreadystatechange = () => {
                if (httpRequest.readyState == 4) {
                    if (httpRequest.status == 200) {
                        console.log(httpRequest.responseText)
                        onSuccess(JSON.parse(httpRequest.responseText))
                    } else if (httpRequest.status == 401) {
                        this.handleTokenError(httpRequest.responseText);
                    } else {
                        if (onError) {
                            onError(httpRequest.status)
                        }
                    }
                }
            }
            httpRequest.open( request.method, url, true )
            httpRequest.setRequestHeader("Authorization", this.authentication.token)
            if (request.isJson) {
                httpRequest.setRequestHeader("Content-Type", "application/json")
            }
            httpRequest.send( request.body )
        }
    }

    handleTokenError(responseText) {
        try {
            const errorResponse = JSON.parse(responseText);
            if (errorResponse.error === "token_expired" || errorResponse.error === "invalid_token") {
                console.log("Token error detected:", errorResponse.error);
                if (this.onLogout) {
                    this.onLogout();
                }
            }
        } catch (e) {
            console.error("Failed to parse error response:", e);
            // Если не удалось распарсить ответ, все равно вызываем logout на 401
            if (this.onLogout) {
                this.onLogout();
            }
        }
    }

    authenticateWithGoogle(idToken, onSuccess) {
        const request = {
            method: "POST",
            endpoint: "auth",
            isJson: true,
            body: JSON.stringify({ token: idToken })
        }
    
        this.send(request, onSuccess, (error_code) => { 
            track('auth_completed', { provider: 'google', success: false,  error_code: error_code });
        })
    }

    markVocabularyWordKnown(wordId, onSuccess, onError) {
        const request = {
          endpoint: "markVocabularyWordKnown",
          params: `wordId=${encodeURIComponent(wordId)}`,
          method: "GET"
        }
        this.send(request, onSuccess, onError)
    }

    trainVocabularyWord(wordId, onSuccess, onError) {
        const request = {
          endpoint: "trainVocabularyWord",
          params: `wordId=${encodeURIComponent(wordId)}`,
          method: "GET"
        }
        this.send(request, onSuccess, onError)
    }

    markDefinitionAsTrained(word, id, onSuccess, onError) {
        const request = {
          endpoint: "markDefinitionAsTrained",
          params: `word=${word}&id=${id}`,
          method: "GET"
        }
    
        this.send(request, onSuccess, onError)
    }

    trainDefinition(word, id, onSuccess, onError) {
        const request = {
          endpoint: "trainDefinition",
          params: `word=${word}&id=${id}`,
          method: "GET"
        }
    
        this.send(request, onSuccess, onError)
    }

    removeDefinition(word, id, onSuccess, onError) {
        const request = {
          endpoint: "removeDefinition",
          params: `word=${word}&id=${id}`,
          method: "GET"
        }
    
        this.send(request, onSuccess, onError)
    }

    repeatDefinition(word, id, onSuccess, onError) {
        const request = {
          endpoint: "repeatDefinition",
          params: `word=${word}&id=${id}`,
          method: "GET"
        }
    
        this.send(request, onSuccess, onError)
    }
}


export default NetworkService
