from django.core.management.base import BaseCommand, CommandError
from django.core.management import call_command

from catmaid.models import *
from catmaid.fields import *

class Command(BaseCommand):
    help = "Create L1EM project in CATMAID"

    def add_arguments(self, parser):
        parser.add_argument('--user', dest='user_id', required=True,
            help='The ID of the user to own the example projects')
    
    def handle(self, *args, **options):

        if not options['user_id']:
            raise CommandError("You must specify a user ID with --user")

        user = User.objects.get(pk=options['user_id'])

        projects = {'Drosophila Larval EM L1': {'stacks': []}}

        # Define the details of a stack the project:

        projects['Drosophila Larval EM L1']['stacks'].append(
            {'title': 'acardona_0111_8',
             'dimension': Integer3D(32768,32768,4840),
             'resolution': Double3D(1.0,1.0,1.0),
             'image_base': 'http://openconnecto.me/ocptilecache/tilecache/acardona_0111_8/image/xy/',
             'file_extension': 'png',
             'num_zoom_levels': 6, 
             'orientation': 0, 
             'comment': '''<p></p>''',
             'tile_height': 512, 
             'tile_source_type': 1, 
             'tile_width': 512, 
             'trakem2_project': False})

        # Remove example Projects:
        demo_project=Project.objects.get(title='Default Project')
        demo_project.delete()
        demo_project=Project.objects.get(title='Evaluation data set')
        demo_project.delete()
        demo_project=Project.objects.get(title='Focussed Ion Beam (FIB)')
        demo_project.delete()
        
        # Make sure that project and its stacks exist, and are
        # linked via ProjectStack:

        for project_title in projects:
            project_object, _ = Project.objects.get_or_create(
                title=project_title)
            for stack_dict in projects[project_title]['stacks']:
                try:
                    stack = Stack.objects.get(
                        title=stack_dict['title'],
                        image_base=stack_dict['image_base'])
                except Stack.DoesNotExist:
                    stack = Stack(**stack_dict)
                    stack.save()
                ProjectStack.objects.get_or_create(
                    project=project_object,
                    stack=stack)
            projects[project_title]['project_object'] = project_object


        
