const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');
const sqlite3 = require('sqlite3').verbose();

const parser = new xml2js.Parser();
const db = new sqlite3.Database('./romnames.db');

if (process.argv.length == 4) {
  db.serialize(function() {
    const stmt = db.prepare('UPDATE romnames SET name = ? WHERE system = ? AND shortname = ?');
    fs.readFile(process.argv[2], function(err, data) {
      parser.parseString(data, function(err, result) {
        for (const game of result.gameList.game) {
          stmt.run(game.name[0], path.dirname(process.argv[2]), path.parse(game.path[0]).filename);
        }
        stmt.finalize();
        db.close();
      });
    });
  });
} else if (process.argv.length == 3) {
  db.run('CREATE TABLE IF NOT EXISTS romnames(system varchar2, shortname varchar2, name varchar2, ename varchar2)');

  db.serialize(function() {
    const stmt = db.prepare('INSERT INTO romnames(system, shortname, name, ename) VALUES (?, ?, ?, ?)');
    fs.readFile(process.argv[2], function(err, data) {
      parser.parseString(data, function(err, result) {
        for (const game of result.gameList.game) {
          stmt.run(path.dirname(process.argv[2]), path.parse(game.path[0]).filename, game.name[0], path.parse(game.path[0])).filename;
        }
        stmt.finalize();
        db.close();
      });
    });
  });
}
