import os
import re

# Configuration
SOURCE_DIR = r"D:\do_an_tot_nghiep\locker_korea\Backend\src\main\java\com\example\Sneakers\models"
OUTPUT_FILE = r"D:\do_an_tot_nghiep\locker_korea\LockerKorea_Analysis_Class_Diagram.puml"

def parse_java_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    class_name_match = re.search(r'public class (\w+)', content)
    if not class_name_match:
        return None
    
    class_name = class_name_match.group(1)
    
    # Remove comments
    content = re.sub(r'//.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

    fields = []
    relationships = []

    # Split by lines to process annotations and fields
    lines = content.split('\n')
    
    current_annotations = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if line.startswith('@'):
            current_annotations.append(line)
            continue
            
        # Match field definition: private Type name;
        # We ignore static fields for analysis diagram usually, but let's keep instance fields
        field_match = re.match(r'private\s+([\w<>?,\s]+)\s+(\w+);', line)
        if field_match:
            field_type = field_match.group(1).strip()
            field_name = field_match.group(2).strip()
            
            # Check for relationships in annotations
            is_relationship = False
            relation_type = None
            cascade = False
            
            full_annotation_str = " ".join(current_annotations)
            
            if '@OneToMany' in full_annotation_str:
                is_relationship = True
                relation_type = 'OneToMany'
                if 'CascadeType.ALL' in full_annotation_str or 'orphanRemoval = true' in full_annotation_str:
                    cascade = True
                
                # Extract generic type from List<Type>
                generic_match = re.search(r'<(\w+)>', field_type)
                if generic_match:
                    target_class = generic_match.group(1)
                    relationships.append({
                        'type': 'OneToMany',
                        'target': target_class,
                        'cascade': cascade,
                        'field': field_name
                    })

            elif '@ManyToOne' in full_annotation_str:
                is_relationship = True
                relationships.append({
                    'type': 'ManyToOne',
                    'target': field_type,
                    'field': field_name
                })

            elif '@OneToOne' in full_annotation_str:
                is_relationship = True
                relationships.append({
                    'type': 'OneToOne',
                    'target': field_type,
                    'field': field_name
                })
            
            elif '@ManyToMany' in full_annotation_str:
                is_relationship = True
                generic_match = re.search(r'<(\w+)>', field_type)
                if generic_match:
                    target_class = generic_match.group(1)
                    relationships.append({
                        'type': 'ManyToMany',
                        'target': target_class,
                        'field': field_name
                    })

            if not is_relationship:
                # It's a normal attribute
                # Simplify type (remove package names if any)
                simple_type = field_type.split('.')[-1]
                fields.append(f"{field_name} : {simple_type}")
            
            current_annotations = [] # Reset for next field
        
        elif 'class ' in line:
            # Reset annotations if we hit the class definition line (though we parsed it earlier)
            current_annotations = []

    return {
        'name': class_name,
        'fields': fields,
        'relationships': relationships
    }

def generate_plantuml(classes):
    puml = ["@startuml"]
    puml.append("skinparam classAttributeIconSize 0") # Use text visibility instead of icons if needed, or default
    puml.append("skinparam linetype ortho")
    
    # Add classes
    for cls in classes:
        puml.append(f"class {cls['name']} {{")
        for field in cls['fields']:
            puml.append(f"  - {field}")
        puml.append("}")
    
    # Add relationships
    # To avoid duplicates, we can track processed pairs, but direction matters.
    # We will prefer OneToMany to draw the aggregation/composition.
    
    for cls in classes:
        source = cls['name']
        for rel in cls['relationships']:
            target = rel['target']
            
            # Skip if target is not in our parsed classes (e.g. standard Java classes)
            if not any(c['name'] == target for c in classes):
                continue

            if rel['type'] == 'OneToMany':
                # Aggregation or Composition
                # Source has List<Target>
                arrow = "*--" if rel['cascade'] else "o--"
                puml.append(f'{source} "1" {arrow} "0..*" {target}')
            
            elif rel['type'] == 'OneToOne':
                puml.append(f'{source} "1" -- "1" {target}')
            
            # We usually don't draw ManyToOne if we draw the OneToMany counterpart.
            # But if it's unidirectional ManyToOne, we should draw it.
            # For now, let's skip ManyToOne to avoid double edges, assuming bidirectional or OneToMany covers it.
            # If there is ONLY ManyToOne (no OneToMany on the other side), we might miss it.
            # Let's check if the other side has OneToMany.
            elif rel['type'] == 'ManyToOne':
                # Check if target has OneToMany back to source
                target_cls = next((c for c in classes if c['name'] == target), None)
                has_reverse = False
                if target_cls:
                    for target_rel in target_cls['relationships']:
                        if target_rel['type'] == 'OneToMany' and target_rel['target'] == source:
                            has_reverse = True
                            break
                
                if not has_reverse:
                    # Draw association
                    puml.append(f'{source} "*" --> "1" {target}')

            elif rel['type'] == 'ManyToMany':
                 puml.append(f'{source} "*" -- "*" {target}')

    puml.append("@enduml")
    return "\n".join(puml)

def main():
    classes = []
    if not os.path.exists(SOURCE_DIR):
        print(f"Directory not found: {SOURCE_DIR}")
        return

    for filename in os.listdir(SOURCE_DIR):
        if filename.endswith(".java"):
            file_path = os.path.join(SOURCE_DIR, filename)
            class_data = parse_java_file(file_path)
            if class_data:
                classes.append(class_data)
    
    puml_content = generate_plantuml(classes)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(puml_content)
    
    print(f"Generated PlantUML file at: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
