import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/event_provider.dart';
import '../../../groups/presentation/providers/group_provider.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../contacts/presentation/notifiers/contact_list_notifier.dart';
import '../../../../core/di/service_locator.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedInvitees = [];
  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    // Fetch groups when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
      // Contacts are fetched automatically by ContactListNotifier constructor
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleInvitee(String inviteeId) {
    setState(() {
      if (_selectedInvitees.contains(inviteeId)) {
        _selectedInvitees.remove(inviteeId);
      } else {
        _selectedInvitees.add(inviteeId);
      }
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final eventProvider = context.read<EventProvider>();
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Get current user ID from Supabase auth
    final currentUserId = sl<SupabaseClient>().auth.currentUser!.id;

    final success = await eventProvider.createNewEvent(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      date: combinedDateTime,
      location: _locationController.text.trim(),
      creatorId: currentUserId,
      groupId: _selectedGroup?.id,
      inviteeIds: _selectedInvitees,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );

      context.pop(); // Go back to previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.error ?? 'Failed to create event'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final contactListNotifier = context.watch<ContactListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          if (eventProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _createEvent, child: const Text('Create')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Event Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(_selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Group Selection
            DropdownButtonFormField<Group>(
              decoration: const InputDecoration(
                labelText: 'Select Group (Optional)',
                border: OutlineInputBorder(),
              ),
              value: _selectedGroup,
              items: groupProvider.groups.map((group) {
                return DropdownMenuItem<Group>(
                  value: group,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (Group? newGroup) {
                setState(() {
                  _selectedGroup = newGroup;
                });
              },
              hint: const Text('Choose a group for this event'),
            ),
            if (_selectedGroup != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  'All members of ${_selectedGroup!.name} will be automatically invited.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Invitees Section
            const Text(
              'Invite People',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (contactListNotifier.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (contactListNotifier.contacts.isEmpty)
              const Text('No contacts found')
            else
              ...contactListNotifier.contacts.map(
                (contact) => CheckboxListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.email ?? ''),
                  value: _selectedInvitees.contains(contact.id),
                  onChanged: (bool? selected) {
                    if (selected != null) {
                      _toggleInvitee(contact.id);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
