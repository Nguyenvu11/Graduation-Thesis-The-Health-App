import 'package:heal_the_health_app/constants/imports.dart';
import 'package:heal_the_health_app/home/appointment/date_time.dart';

class UpcomingCard extends StatelessWidget {
  UpcomingCard({super.key});
  DoctorUser doctor = DoctorUser();
  final bool _isLoaded = false;

  String getDayString(Appointment appointment) {
    if (appointment.dateTime!.year == DateTime.now().year &&
        appointment.dateTime!.month == DateTime.now().month) {
      if (appointment.dateTime!.day == DateTime.now().day) {
        return '${appointment.date}, Today';
      } else if (appointment.dateTime!.day == DateTime.now().day + 1) {
        return '${appointment.date}, Tomorrow';
      } else {
        return '${appointment.date}, ${DateConverted.getDay(appointment.dateTime!.weekday)}';
      }
    } else {
      return '${appointment.date} ,${DateConverted.getDay(appointment.dateTime!.weekday)}';
    }
  }

  Future<void> getDoctorHere(String uid) async {
    doctor = await DoctorUser().getDoctor(uid);
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    Widget showImage() {
      if (doctor.imageUrl != '') {
        return Image.network(
          doctor.imageUrl,
          width: 60,
          height: 80,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          'images/doctor_profile.png',
          width: 60,
          height: 80,
          fit: BoxFit.cover,
        );
      }
    }

    if (authNotifier.patientDetails!.upcoming!.isNotEmpty) {
      List<Appointment> upcoming = authNotifier.patientDetails!.upcoming!;
      return Material(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Appointments()));
          },
          child: Container(
            width: double.infinity, // Use double.infinity for flexible width
            height: 110,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: _isLoaded
                ? const Text('Already loaded')
                : FutureBuilder(
                    future: getDoctorHere(upcoming[0].doctor ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize
                              .min, // Prevent Row from expanding beyond its content
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: showImage(),
                            ),
                            10.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 17,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          // Wrap Text widget with Expanded to take available space
                                          child: Text(
                                            'Dr. ${doctor.name}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Prevent overflow
                                          ),
                                        ),
                                        10.widthBox,
                                        Text(
                                          doctor.specialization,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.3,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Prevent overflow here
                                        ),
                                      ],
                                    ),
                                  ),
                                  5.heightBox,
                                  SizedBox(
                                    height: 20,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            doctor.hospitalName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              wordSpacing: 2,
                                              letterSpacing: 0.2,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Prevent overflow here
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  6.heightBox,
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Ionicons.calendar_outline,
                                            size: 9,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, right: 0, top: 2),
                                            child: Text(
                                              getDayString(upcoming[0]),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow
                                                  .ellipsis, // Prevent overflow for text
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(right: 3),
                                            child: Icon(
                                              Ionicons.time_outline,
                                              size: 7,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            upcoming[0].time ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400),
                                            overflow: TextOverflow
                                                .ellipsis, // Prevent overflow for text
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
          ),
        ),
      );
    } else {
      return Container(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12)),
          child: const Center(
              child: Text(
            'No Upcoming Appointments',
            style: TextStyle(fontSize: 16, color: Colors.white),
          )));
    }
  }
}
