import 'dart:io';

import 'package:contatos/UI/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("lib/images/user.png"))),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: () {
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Ligar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            },
                            child: Text(
                              "Editar",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                            onPressed: () {
                              helper.deleteContact(contacts[index].id);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                            child: Text(
                              "Exclui",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContact();
    }
  }

  void _getAllContact() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}
