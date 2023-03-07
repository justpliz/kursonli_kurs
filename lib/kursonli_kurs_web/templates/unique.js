const fs = require('fs');

fs.readFile("default.txt", "utf-8", (err, data) => {
    if (err) throw err;

    const newFile = data.match(/msgid\s".+"/g).filter(onlyUnique).map((el) => {
        return `${el}\nmsgstr ""`

    }).join("\n\n")

    fs.writeFile("default.txt", newFile, function (err) {
        if (err) throw err;
        console.log("COMPLETED UNIQ JS")

    });
});
function onlyUnique(value, index, self) {
    return self.indexOf(value) === index;
}