
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/ai_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/ai_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/ai_state.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/medicine_details_page.dart';
import 'package:medlink_mobileapp/service_locator.dart';


class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  final TextEditingController _descriptionController = TextEditingController();
  late String token;
  List<Map<String, dynamic>> messages = [
    {'sender': 'ai', 'text': 'Hello, I\'m Medlink Chatbot. How can I help you today?'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['token'] != null) {
      token = args['token'] as String;
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _sendMessage(String description) {
    if (description.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'text': description});
      });
      context.read<AiBloc>().add(AskAiEvent(description: description, token: token));
      _descriptionController.clear();
    }
  }

  void _searchMedicine(String name) {
    context.read<AiBloc>().add(GetMedicineByNameEvent(name: name, token: token));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AiBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white ,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'MedLink AI Chatbot',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2b8761),
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocConsumer<AiBloc, AiState>(
          listener: (context, state) {
            if (state is AiResponseLoaded) {
              setState(() {
                messages.add({
                  'sender': 'ai',
                  'text': state.response.explanation,
                  'medicines': state.response.medicines,
                });
              });
            } else if (state is MedicinesLoaded) {
              if (state.medicines.isNotEmpty) {
                final medicine = state.medicines.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineDetailsPage(
                      medicineId: medicine.id,
                      token: token,
                    ),
                  ),
                );
              } else {
                setState(() {
                  messages.add({
                    'sender': 'ai',
                    'text': "We couldn't find the medicine yet. You'll get notified when we have it in stock.",
                  });
                });
              }
            } else if (state is AiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF2b8761) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text']!,
                                style: GoogleFonts.poppins(
                                  color: isUser ? Colors.white : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (message['medicines'] != null && message['medicines'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Recommended Medicines:',
                                  style: GoogleFonts.poppins(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...List.generate(
                                  message['medicines'].length,
                                  (i) => Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: ListTile(
                                      title: Text(
                                        message['medicines'][i],
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      onTap: () {
                                        _searchMedicine(message['medicines'][i]);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Note: This is an AI recommendation. Please cross-check the medicines and conduct further research before making any decisions.',
                                  style: GoogleFonts.poppins(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontSize: 14,
                                    
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Describe your symptoms...',
                            hintStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _sendMessage(_descriptionController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2b8761),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.send, color: Colors.white,),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}