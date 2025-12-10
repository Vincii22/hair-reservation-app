import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/models/service.dart';

class AddEditServiceScreen extends StatefulWidget {
  // If service is provided, we are in 'Edit' mode. If null, we are in 'Add' mode.
  final Service? service; 

  const AddEditServiceScreen({super.key, this.service});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();

  // Firestore Instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'Haircut'; // Default category
  bool _isActive = true;

  // Placeholder Categories for the dropdown (Admin can manage these later)
  final List<String> _categories = [
    'Haircut', 
    'Coloring', 
    'Treatment', 
    'Styling', 
    'Beard'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if we are in Edit mode
    if (widget.service != null) {
      nameController.text = widget.service!.name;
      priceController.text = widget.service!.price.toString();
      durationController.text = widget.service!.durationMinutes.toString();
      _selectedCategory = widget.service!.category;
      _isActive = widget.service!.isActive;
    }
  }

  // --- Service Creation/Update Logic ---
  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Convert inputs to correct types
      final double price = double.parse(priceController.text.trim());
      final int duration = int.parse(durationController.text.trim());

      // 2. Create the Service Map
      final Service newServiceData = Service(
        id: widget.service?.id ?? '', // Use existing ID or placeholder
        name: nameController.text.trim(),
        category: _selectedCategory,
        price: price,
        durationMinutes: duration,
        isActive: _isActive,
      );

      // 3. Determine if we are creating or updating
      if (widget.service == null) {
        // --- ADD NEW SERVICE ---
        await _firestore.collection('services').add(newServiceData.toMap());
      } else {
        // --- EDIT EXISTING SERVICE ---
        await _firestore.collection('services').doc(widget.service!.id).update(newServiceData.toMap());
      }

      // 4. Success feedback and close screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newServiceData.name} saved successfully!')),
      );
      Navigator.of(context).pop(); // Go back to ManageServicesScreen

    } on FormatException {
      setState(() {
        _errorMessage = 'Please enter valid numbers for Price and Duration.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while saving the service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.service != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: isEditing ? 'Edit Service' : 'Add New Service', hasBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 1. Service Name Field
                Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                MyTextField(
                  controller: nameController,
                  hintText: 'e.g., Classic Haircut, Full Color',
                  icon: Icons.cut,
                  obscureText: false,
                  validator: (value) => value!.isEmpty ? 'Name cannot be empty.' : null,
                ),
                const SizedBox(height: 20),

                // 2. Category Dropdown
                Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.category, color: Colors.teal),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // 3. Price Field
                Text('Price (\$)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                MyTextField(
                  controller: priceController,
                  hintText: 'e.g., 50.00',
                  icon: Icons.attach_money,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid price.' : null,
                ),
                const SizedBox(height: 20),
                
                // 4. Duration Field
                Text('Duration (Minutes)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                MyTextField(
                  controller: durationController,
                  hintText: 'e.g., 45',
                  icon: Icons.timer,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter duration in minutes.' : null,
                ),
                const SizedBox(height: 30),

                // 5. Active Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Service is Active', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 30),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Save Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                    : MyButton(
                        text: isEditing ? "Update Service" : "Add Service",
                        onTap: _saveService,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}