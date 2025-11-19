import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/repositories/contact_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return const Center(child: Text("No contacts found!"));
                    }

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact["name"]),
                        );
                      },
                      itemCount: contacts.length,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              getIt<AuthCubit>().signOut();
            },
            child: Icon(Icons.logout),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text("Chats"),
      ),
      body: Center(
        child: Text(
          "User is AUTHENTICATED",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.brown),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactList(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
