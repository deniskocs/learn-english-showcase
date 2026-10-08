// buttonBehavior.js
// Общая логика для кнопок: loading и error состояния

export function addButtonBehavior(button, originalText) {
    // Сохраняем оригинальный текст и HTML
    button._originalText = originalText;
    // Сохраняем текущее содержимое, если оно было установлено через innerHTML
    // Иначе используем текст как HTML
    button._originalHTML = button.innerHTML || originalText;
    
    // Метод для отображения состояния загрузки
    button.displayLoading = function() {
        this.disabled = true;
        this.classList.add("btn-loading");
        this.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>' + this._originalText;
    };
    
    // Метод для отображения ошибки
    button.displayError = function() {
        this.disabled = false;
        this.classList.remove("btn-loading");
        this.classList.add("btn-error");
        this.innerHTML = '<span class="btn-error-icon">⚠</span>';
        
        const buttonRef = this;
        setTimeout(() => {
            buttonRef.classList.remove("btn-error");
            buttonRef.innerHTML = buttonRef._originalHTML;
        }, 500);
    };
    
    // Метод для сброса в нормальное состояние
    button.reset = function() {
        this.disabled = false;
        this.classList.remove("btn-loading", "btn-error");
        this.innerHTML = this._originalHTML;
    };
    
    return button;
}

