import '../domain/chat_models.dart';

final mockThreads = <ChatThread>[
  ChatThread(
    id: '1',
    title: 'Sarah M. (Caregiver)',
    lastMessage: 'I can start tomorrow morning.',
    updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    unread: 1,
  ),
  ChatThread(
    id: '2',
    title: 'AllCare Support',
    lastMessage: 'Your request is live.',
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    unread: 0,
  ),
];

final mockMessages = <ChatMessage>[
  ChatMessage(
    id: 'm1',
    text: 'Hi, I’m interested in your request.',
    fromMe: false,
    sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  ChatMessage(
    id: 'm2',
    text: 'Great! When can you start?',
    fromMe: true,
    sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
];
