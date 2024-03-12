String cap(String s) => s[0].toUpperCase() + s.substring(1);

// String capitalizeEachWord(String text) {
//   return text.toLowerCase().split(' ').map((word) {
//     return capitalize(word);
//   }).join(' ');
// }

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
