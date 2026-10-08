export default function EmptyBody(text, colSpan = 3) {
    const tbody = document.createElement("tbody")
    const emptyRow = document.createElement("tr")
    const emptyCell = document.createElement("td")
  
    emptyCell.colSpan = colSpan
    emptyCell.className = "text-center text-muted py-5"
    emptyCell.textContent = text
  
    emptyRow.appendChild(emptyCell)
    tbody.appendChild(emptyRow)
    return tbody
}