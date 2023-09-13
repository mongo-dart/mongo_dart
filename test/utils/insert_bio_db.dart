import 'package:bson/bson.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<(BulkWriteResult, MongoDocument, List<MongoDocument>, List<dynamic>)>
    insertBio(MongoCollection collection) async {
  return collection.insertMany([
    {
      '_id': 1,
      'name': {'first': 'John', 'last': 'Backus'},
      'birth': DateTime.parse('1924-12-03T05:00:00Z'),
      "death": DateTime.parse("2007-03-17T04:00:00Z"),
      "contribs": ["Fortran", "ALGOL", "Backus-Naur Form", "FP"],
      "awards": [
        {
          "award": "W.W. McDowell Award",
          "year": 1967,
          "by": "IEEE Computer Society"
        },
        {
          "award": "National Medal of Science",
          "year": 1975,
          "by": "National Science Foundation"
        },
        {"award": "Turing Award", "year": 1977, "by": "ACM"},
        {
          "award": "Draper Prize",
          "year": 1993,
          "by": "National Academy of Engineering"
        }
      ]
    },
    {
      "_id": ObjectId.parse("51df07b094c6acd67e492f41"),
      "name": {"first": "John", "last": "McCarthy"},
      "birth": DateTime.parse("1927-09-04T04:00:00Z"),
      "death": DateTime.parse("2011-12-24T05:00:00Z"),
      "contribs": ["Lisp", "Artificial Intelligence", "ALGOL"],
      "awards": [
        {"award": "Turing Award", "year": 1971, "by": "ACM"},
        {"award": "Kyoto Prize", "year": 1988, "by": "Inamori Foundation"},
        {
          "award": "National Medal of Science",
          "year": 1990,
          "by": "National Science Foundation"
        }
      ]
    },
    {
      "_id": 3,
      "name": {"first": "Grace", "last": "Hopper"},
      "title": "Rear Admiral",
      "birth": DateTime.parse("1906-12-09T05:00:00Z"),
      "death": DateTime.parse("1992-01-01T05:00:00Z"),
      "contribs": ["UNIVAC", "compiler", "FLOW-MATIC", "COBOL"],
      "awards": [
        {
          "award": "Computer Sciences Man of the Year",
          "year": 1969,
          "by": "Data Processing Management Association"
        },
        {
          "award": "Distinguished Fellow",
          "year": 1973,
          "by": " British Computer Society"
        },
        {
          "award": "W. W. McDowell Award",
          "year": 1976,
          "by": "IEEE Computer Society"
        },
        {
          "award": "National Medal of Technology",
          "year": 1991,
          "by": "United States"
        }
      ]
    },
    {
      "_id": 4,
      "name": {"first": "Kristen", "last": "Nygaard"},
      "birth": DateTime.parse("1926-08-27T04:00:00Z"),
      "death": DateTime.parse("2002-08-10T04:00:00Z"),
      "contribs": ["OOP", "Simula"],
      "awards": [
        {
          "award": "Rosing Prize",
          "year": 1999,
          "by": "Norwegian Data Association"
        },
        {"award": "Turing Award", "year": 2001, "by": "ACM"},
        {"award": "IEEE John von Neumann Medal", "year": 2001, "by": "IEEE"}
      ]
    },
    {
      "_id": 5,
      "name": {"first": "Ole-Johan", "last": "Dahl"},
      "birth": DateTime.parse("1931-10-12T04:00:00Z"),
      "death": DateTime.parse("2002-06-29T04:00:00Z"),
      "contribs": ["OOP", "Simula"],
      "awards": [
        {
          "award": "Rosing Prize",
          "year": 1999,
          "by": "Norwegian Data Association"
        },
        {"award": "Turing Award", "year": 2001, "by": "ACM"},
        {"award": "IEEE John von Neumann Medal", "year": 2001, "by": "IEEE"}
      ]
    },
    {
      "_id": 6,
      "name": {"first": "Guido", "last": "van Rossum"},
      "birth": DateTime.parse("1956-01-31T05:00:00Z"),
      "contribs": ["Python"],
      "awards": [
        {
          "award": "Award for the Advancement of Free Software",
          "year": 2001,
          "by": "Free Software Foundation"
        },
        {"award": "NLUUG Award", "year": 2003, "by": "NLUUG"}
      ]
    },
    {
      "_id": ObjectId.parse("51e062189c6ae665454e301d"),
      "name": {"first": "Dennis", "last": "Ritchie"},
      "birth": DateTime.parse("1941-09-09T04:00:00Z"),
      "death": DateTime.parse("2011-10-12T04:00:00Z"),
      "contribs": ["UNIX", "C"],
      "awards": [
        {"award": "Turing Award", "year": 1983, "by": "ACM"},
        {
          "award": "National Medal of Technology",
          "year": 1998,
          "by": "United States"
        },
        {
          "award": "Japan Prize",
          "year": 2011,
          "by": "The Japan Prize Foundation"
        }
      ]
    },
    {
      "_id": 8,
      "name": {"first": "Yukihiro", "aka": "Matz", "last": "Matsumoto"},
      "birth": DateTime.parse("1965-04-14T04:00:00Z"),
      "contribs": ["Ruby"],
      "awards": [
        {
          "award": "Award for the Advancement of Free Software",
          "year": "2011",
          "by": "Free Software Foundation"
        }
      ]
    },
    {
      "_id": 9,
      "name": {"first": "James", "last": "Gosling"},
      "birth": DateTime.parse("1955-05-19T04:00:00Z"),
      "contribs": ["Java"],
      "awards": [
        {
          "award": "The Economist Innovation Award",
          "year": 2002,
          "by": "The Economist"
        },
        {
          "award": "Officer of the Order of Canada",
          "year": 2007,
          "by": "Canada"
        }
      ]
    },
    {
      "_id": 10,
      "name": {"first": "Martin", "last": "Odersky"},
      "contribs": ["Scala"]
    }
  ]);
}
