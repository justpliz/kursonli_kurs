const folder = process.argv[2]
const isEex = process.argv[3]
const fs = require('fs');

//   >(\s+)?([А-яЯ-а:]+|([А-яЯ-а:-]+\s+?([А-я:-])+)+)(\s+)?< || >(\s+)?([А-яЯ-а:()]+|([А-яЯ-а:()-]+\s+?([А-я:()-]?)+)+)(\s+)?<

// >(\s+)?([А-яЯ-а:/()]+|([А-яЯ-а:/()-]+\s+?([А-я:/()-]?)+)+)(\s+)?<
fs.open('default.txt', 'r+', (err) => {
    if (err) throw err;
    console.log('File created');
});
fs.readdir(folder, (err, files) => {
    if (err) throw err;

    files.forEach(file => {

        fs.readFile(folder + file, "utf-8", (err, data) => {

            let newFile = data
            if (err) throw err;

            if (isEex == "html|eex") {
                newFile = newFile.replace(/>(\s+|\n+)?([A-zА-яЯ-аё!?0-9№():.-]+|([A-zА-яЯ-а0-9№:ё!?().:-]+\s+?([A-zА-яЯ-а0-9№ё!?().:-]?)+)+)(\s+|\n+)?</g, (match) => {
                    if (!/>(\s+\n+)?[A-zZ-a:()\s]+(\s+|\n+)?</g.test(match))
                        return match.replace(/(<|>)/g, "").trim().replace(/.+/, (match) => {
                            fs.appendFile('default.txt', `msgid "${match}"\nmsgstr ""\n\n`, (err) => {

                                console.log('Data_msgid --->', match)
                            });
                            return `><%= gettext("${match}") %><`
                        })
                    else
                        return match
                })
                newFile = newFile.replace(/"[^A-z\d"'\n()@,=>]+"/gi, (match) => {

                    fs.appendFile('default.txt', `msgid "${match}"\nmsgstr ""\n\n`, (err) => {
                        console.log('DATA STRING --->', match);
                    });
                    return `'#{gettext(${match})}'`
                })

            }
            else if (isEex == "eex") {
                newFile = newFile.replace(/"[^A-z\d"'\n()@,=>|/]+"/gi, (match) => {

                    fs.appendFile('default.txt', `msgid "${match}"\nmsgstr ""\n\n`, (err) => {
                        console.log('DATA STRING --->', match);
                    });
                    return `gettext(${match})`
                })


            } else {
                newFile = newFile.replace(/>(\s+|\n+)?([A-zА-яЯ-аё!?0-9№():.-]+|([A-zА-яЯ-а0-9№:ё!?().:-]+\s+?([A-zА-яЯ-а0-9№ё!?().:-]?)+))(\s+|\n+)?</g, (match) => {
                    if (!/>(\s+\n+)?[A-zZ-a:()\s]+(\s+|\n+)?</g.test(match))
                        return match.replace(/(<|>)/g, "").trim().replace(/.+/, (match) => {
                            fs.appendFile('default.txt', `msgid "${match}"\nmsgstr ""\n\n`, (err) => {

                                console.log('Data_msgid --->', match)
                            });
                            return `><%= gettext("${match}") %><`
                        })
                    else
                        return match
                })
            }


            fs.writeFile(folder + file, newFile, function (err) {
                console.log('complete ----> ' + folder + file);
                if (err) throw err;

            });

        })

    });

});

         // >(\s+|\n+)?([A-zА-яЯ-а:/]+|([A-zА-яЯ-а:/-]+\s+?([A-zА-я:/-]?)+)+)(\s+|\n+)?<
            // >(\s+)?([А-яЯ-а:/]+|([А-яЯ-а:/-]+\s+?([А-я:/-]?)+)+)(\s+)?<

 // newFile = newFile.replace(/"[^A-z\d]+"/, (match) => {

            //     fs.appendFile('default.txt', `msgid "${match}"\nmsgstr ""\n\n`, (err) => {
            //         console.log('DATA STRING --->', match);
            //     });
            //     return `'#{gettext(${match})}'`
            // })



