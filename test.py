# Input string
input_str = "Iron Man,Captain America,Thor,Spider Man,Docter Strage,Black Panther,Ant Man,Captain Marvel,Hulk,Black Widow,Hawkeye Avengers,Scarlet Witch,Vision Avengers,Bucky Barnes,Falcon Avengers,Loki"

# Split the string into a list of names
names = input_str.split(",")

# Create a list of formatted strings
formatted_names = [f"\"{name}\" : \"{name.replace(' ', '_')}.mp3\"," for name in names]

# Print the result
for item in formatted_names:
    print(item)
