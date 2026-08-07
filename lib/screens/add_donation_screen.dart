import 'package:flutter/material.dart';

import '../models/donation.dart'; // Provides the Donation model and DonationStatus values.
import '../services/donation_repository.dart'; // methods to save the new donation
import '../widgets/donation_form.dart'; // "reusable form" being used to collect donation data

// page is made to create and add new donation
class AddDonationScreen extends StatelessWidget {
  const AddDonationScreen({
    super.key,
    required this.donationRepository,
    required this.currentDonorId,
  });

  // connecting to donation repository
  final DonationRepository donationRepository;
  final String currentDonorId; // donar ID stored

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Donation'),
      ),
      body: DonationForm(
        submitButtonText: 'Publish Donation',
        // formdata contain all the donar info added like food name,pickup address.. etc

        onSubmit: (formData) async {
          final now = DateTime.now(); // current date and time so it can help with donation ID and when donation creation 
          final donation = Donation(
            id: now.microsecondsSinceEpoch.toString(),// ID unique with timestamp
            donorId: currentDonorId,


            foodName: formData.foodName,
            description: formData.description,
            category: formData.category,
            quantity: formData.quantity,
            servings: formData.servings,
            preparationDate: formData.preparationDate,
            expiryDate: formData.expiryDate,
            allergyInformation: formData.allergyInformation,
            pickupAddress: formData.pickupAddress,
            pickupDateTime: formData.pickupDateTime,
            isFoodSafe: formData.isFoodSafe,
            status: DonationStatus.available,
            createdAt: now,
            imagePath: formData.imagePath,
          );

          await donationRepository.createDonation(donation); // sends the new donation object to donation_repository.dart 

        /*
        Checking to see if the page still avaialble, 
        like if the user left the screen while the donation is being saved.
         */
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation published successfully.'), // message to show the donation is saved successfully
            ),
          );
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
