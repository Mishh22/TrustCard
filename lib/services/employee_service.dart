import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';

class EmployeeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add employee to company
  static Future<bool> addEmployee(Employee employee) async {
    try {
      // Save employee to Firestore
      await _firestore
          .collection('employees')
          .doc(employee.id)
          .set(employee.toMap());

      // Add employee to company's employee list (use set with merge to create if not exists)
      await _firestore
          .collection('company_details')
          .doc(employee.companyId)
          .set({
        'employees': FieldValue.arrayUnion([employee.id]),
      }, SetOptions(merge: true));

      // Log activity
      await _firestore.collection('activityLogs').add({
        'userId': employee.companyId,
        'type': 'employee_added',
        'title': 'Employee Added',
        'details': 'Added employee ${employee.fullName} to company',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'data': {
          'employeeId': employee.id,
          'employeeName': employee.fullName,
          'designation': employee.designation,
        },
      });

      return true;
    } catch (e) {
      print('Error adding employee: $e');
      return false;
    }
  }

  // Update employee
  static Future<bool> updateEmployee(Employee employee) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employee.id)
          .update(employee.toMap());

      // Log activity
      await _firestore.collection('activityLogs').add({
        'userId': employee.companyId,
        'type': 'employee_updated',
        'title': 'Employee Updated',
        'details': 'Updated employee ${employee.fullName}',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'data': {
          'employeeId': employee.id,
          'employeeName': employee.fullName,
        },
      });

      return true;
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }

  // Delete employee
  static Future<bool> deleteEmployee(String employeeId, String companyId) async {
    try {
      // Get employee data before deletion for logging
      final employeeDoc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();

      if (!employeeDoc.exists) return false;

      final employee = Employee.fromMap(employeeDoc.data()!, employeeId);

      // Soft delete - mark as inactive instead of deleting
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update({'isActive': false});

      // Remove from company's employee list
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'employees': FieldValue.arrayRemove([employeeId]),
      });

      // Log activity
      await _firestore.collection('activityLogs').add({
        'userId': companyId,
        'type': 'employee_deleted',
        'title': 'Employee Removed',
        'details': 'Removed employee ${employee.fullName} from company',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'data': {
          'employeeId': employeeId,
          'employeeName': employee.fullName,
        },
      });

      return true;
    } catch (e) {
      print('Error deleting employee: $e');
      return false;
    }
  }

  // Get all employees for a company
  static Future<List<Employee>> getCompanyEmployees(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('employees')
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Employee.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting company employees: $e');
      return [];
    }
  }

  // Stream of employees for real-time updates
  static Stream<List<Employee>> getCompanyEmployeesStream(String companyId) {
    return _firestore
        .collection('employees')
        .where('companyId', isEqualTo: companyId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Employee.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get single employee
  static Future<Employee?> getEmployee(String employeeId) async {
    try {
      final doc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();

      if (doc.exists) {
        return Employee.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting employee: $e');
      return null;
    }
  }

  // Search employees by name or employee ID
  static Future<List<Employee>> searchEmployees(String companyId, String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('employees')
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .get();

      final allEmployees = querySnapshot.docs
          .map((doc) => Employee.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by name or employee ID
      return allEmployees.where((employee) {
        final lowercaseQuery = query.toLowerCase();
        return employee.fullName.toLowerCase().contains(lowercaseQuery) ||
            (employee.employeeId?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching employees: $e');
      return [];
    }
  }
}

