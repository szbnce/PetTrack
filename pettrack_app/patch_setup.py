import re

with open('lib/screens/setup_wizard_screen.dart', 'r') as f:
    content = f.read()

# We want to change the part where it pre-fills the name, to instead automatically finish setup.
# In _processLogin:

old_code = """
          if (petRes.statusCode == 200) {
            final petData = jsonDecode(petRes.body);
            if (petData['name'] != null && petData['name'] != 'Unknown') {
              _nameController.text = petData['name'];
            }
            if (petData['type'] != null && petData['type'] != 'Unknown') {
              String typeVal = petData['type'].toString().toLowerCase();
              if (typeVal.startsWith('pettype')) {
                typeVal = typeVal.replaceFirst('pettype', '');
              }
              _selectedType = typeVal;
            }
          }
        } catch (_) {
          // Ignore errors, just proceed with empty fields
        }

        setState(() {
          _serverIp = ip;
          _secretToken = secret;
          _jwtToken = data['token'];
          _isLoading = false;
        });
        
        await _secureStorage.write(key: 'secret_token', value: secret);

        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
"""

new_code = """
          if (petRes.statusCode == 200) {
            final petData = jsonDecode(petRes.body);
            if (petData['name'] != null && petData['name'] != 'Unknown') {
              _nameController.text = petData['name'];
              String typeVal = (petData['type'] ?? 'dog').toString().toLowerCase();
              if (typeVal.startsWith('pettype')) {
                typeVal = typeVal.replaceFirst('pettype', '');
              }
              _selectedType = typeVal;
              
              // We have an existing pet! Skip the rest of the wizard.
              setState(() {
                _serverIp = ip;
                _secretToken = secret;
                _jwtToken = data['token'];
              });
              await _secureStorage.write(key: 'secret_token', value: secret);
              
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('server_ip', _serverIp!);
              await prefs.setString('secret_token', _secretToken!);
              await prefs.setString('jwt_token', _jwtToken!);
              await prefs.setString('pet_name', _nameController.text.trim());
              await prefs.setString('pet_type', _selectedType);
              await prefs.setBool('is_setup_completed', true);
              
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MainNavigationScreen(
                      serverIp: _serverIp!,
                      token: _jwtToken!,
                      petName: _nameController.text,
                    ),
                  ),
                );
              }
              return; // Exit here, we are done!
            }
          }
        } catch (_) {
          // Ignore errors, just proceed with empty fields
        }

        setState(() {
          _serverIp = ip;
          _secretToken = secret;
          _jwtToken = data['token'];
          _isLoading = false;
        });
        
        await _secureStorage.write(key: 'secret_token', value: secret);

        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
"""

if old_code in content:
    content = content.replace(old_code, new_code)
    with open('lib/screens/setup_wizard_screen.dart', 'w') as f:
        f.write(content)
    print("Patch applied to SetupWizardScreen")
else:
    print("Could not find the target code in SetupWizardScreen")
