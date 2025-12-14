import os
import re
import sys

def generate_plantuml(root_dir, output_file):
    models_dir = os.path.join(root_dir, "Backend/src/main/java/com/example/Sneakers/models")
    
    if not os.path.exists(models_dir):
        print(f"Directory not found: {models_dir}")
        return

    plantuml_content = ["@startuml LockerKorea_Analysis_ClassDiagram", 
                        "skinparam classAttributeIconSize 0",
                        "skinparam linetype ortho",
                        "package \"Domain Models\" {"]

    files = [f for f in os.listdir(models_dir) if f.endswith(".java")]
    
    relationships = []
    
    for file in files:
        class_name = file.replace(".java", "")
        file_path = os.path.join(models_dir, file)
        
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            
            # Check if it's an entity or class
            if "class " not in content and "enum " not in content:
                continue
                
            type_def = "class"
            if "enum " in content:
                type_def = "enum"
            elif "interface " in content:
                type_def = "interface"
            
            plantuml_content.append(f"  {type_def} {class_name} {{")
            
            # Extract fields
            lines = content.split('\n')
            for line in lines:
                line = line.strip()
                # Simple field extraction (private Type name;)
                field_match = re.match(r'private\s+(\w+(?:<[\w\s,?]+>)?)\s+(\w+);', line)
                if field_match:
                    field_type = field_match.group(1)
                    field_name = field_match.group(2)
                    plantuml_content.append(f"    -{field_name} : {field_type}")
                    
                    # Check for relationships based on type or annotations (simplified)
                    # We'll do a second pass or just look for known types if we want strict relationships
                    # But for now, let's rely on annotations if possible, or just type matching
                
                # Check for relationships annotations in previous lines (simplified approach)
                # A better way is to read the whole file and use regex for annotations + field
            
            plantuml_content.append("  }")
            
            # Extract relationships
            # OneToMany
            # @OneToMany(mappedBy = "user")
            # private List<Order> orders;
            one_to_many = re.findall(r'@OneToMany.*?\n\s*private\s+List<(\w+)>\s+(\w+);', content, re.DOTALL)
            for target, field in one_to_many:
                relationships.append(f"  {class_name} \"1\" -- \"0..*\" {target} : {field}")

            # ManyToOne
            # @ManyToOne
            # @JoinColumn(name = "user_id")
            # private User user;
            many_to_one = re.findall(r'@ManyToOne.*?\n(?:\s*@JoinColumn.*?\n)?\s*private\s+(\w+)\s+(\w+);', content, re.DOTALL)
            for target, field in many_to_one:
                relationships.append(f"  {class_name} \"0..*\" -- \"1\" {target} : {field}")

            # OneToOne
            one_to_one = re.findall(r'@OneToOne.*?\n(?:\s*@JoinColumn.*?\n)?\s*private\s+(\w+)\s+(\w+);', content, re.DOTALL)
            for target, field in one_to_one:
                relationships.append(f"  {class_name} \"1\" -- \"1\" {target} : {field}")
                
            # ManyToMany
            many_to_many = re.findall(r'@ManyToMany.*?\n(?:\s*@JoinTable.*?\n)?\s*private\s+(?:List|Set)<(\w+)>\s+(\w+);', content, re.DOTALL)
            for target, field in many_to_many:
                relationships.append(f"  {class_name} \"*\" -- \"*\" {target} : {field}")

    plantuml_content.append("}")
    
    # Add relationships
    for rel in relationships:
        plantuml_content.append(rel)
        
    plantuml_content.append("@enduml")
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(plantuml_content))
    
    print(f"Generated {output_file}")

if __name__ == "__main__":
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    output = sys.argv[2] if len(sys.argv) > 2 else "LockerKorea_Analysis_ClassDiagram.puml"
    generate_plantuml(root, output)
