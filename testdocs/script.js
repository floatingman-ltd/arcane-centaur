// Sample JavaScript for the Bracey live-preview test (index.html).
// Exercises JS treesitter highlight and the save-to-reload flow.

const button = document.getElementById("btn");
let clicks = 0;

function updateTitle(count) {
  const title = document.getElementById("title");
  const plural = count === 1 ? "" : "s";
  title.textContent = `Clicked ${count} time${plural}`;
}

button.addEventListener("click", () => {
  clicks += 1;
  updateTitle(clicks);
});

// A couple of plain functions for highlight / navigation testing.
const add = (a, b) => a + b;

function sumOfSquares(numbers) {
  return numbers.reduce((total, n) => total + n * n, 0);
}

console.log("add(2, 3) =", add(2, 3));
console.log("sumOfSquares =", sumOfSquares([1, 2, 3, 4, 5]));
