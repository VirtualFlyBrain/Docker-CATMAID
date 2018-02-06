from django.core.management.base import BaseCommand, CommandError
from django.core.management import call_command

from catmaid.models import *
from catmaid.fields import *

from guardian.shortcuts import assign_perm
from guardian.utils import get_anonymous_user

class Command(BaseCommand):
    help = "Create FAFB project in CATMAID"

    def add_arguments(self, parser):
        parser.add_argument('--user', dest='user_id', required=True,
            help='The ID of the user to own the example projects')
    
    def handle(self, *args, **options):

        if not options['user_id']:
            raise CommandError("You must specify a user ID with --user")

        user = User.objects.get(pk=options['user_id'])
        anon_user = get_anonymous_user()

        projects = {'FAFB00 [V14]': {'stacks': []}}

        # Define the details of a stack the project:

        projects['FAFB00 [V14]']['stacks'].append(
            {'title': 'FAFB00 V14 (JPG85)',
             'dimension': Integer3D(293952,155648,7063),
             'resolution': Double3D(4.0,4.0,40.0),
             'comment': '''<p></p>''',
             'mirrors': [{
                'title': 'Cambridge',
                'image_base': 'https://flyem.mrc-lmb.cam.ac.uk/fafb-tiles/',
                'file_extension': 'jpg',
                'tile_height': 1024, 
                'tile_width': 1024,
                'tile_source_type': 5 
            }],
             'num_zoom_levels': -1})

        # Remove example Projects:
        demos = StackMirror.objects.all()
        for demo_stack in demos:
            demo_stack.delete()
        
        # Remove example Projects:
        demos = Stack.objects.all()
        for demo_stack in demos:
            demo_stack.delete()
        
        # Remove example Projects:
        demos = Project.objects.all()
        for demo_project in demos:
            demo_project.delete()
        
        # Make sure that each project and its stacks exist, and are
        # linked via ProjectStack:

        for project_title in projects:
            project_object, _ = Project.objects.get_or_create(
                title=project_title)
            for stack_dict in projects[project_title]['stacks']:
                stack, _ = Stack.objects.get_or_create(
                    title=stack_dict['title'],
                    defaults={
                       'dimension': stack_dict['dimension'],
                       'resolution': stack_dict['resolution'],
                    })
                mirrors = list(StackMirror.objects.filter(stack=stack))
                if not mirrors:
                    for m in stack_dict['mirrors']:
                        mirrors.append(StackMirror.objects.create(stack=stack,
                                title=m['title'], image_base=m['image_base'], 
                                file_extension=m['file_extension'], tile_height=m['tile_height'], 
                                tile_width=m['tile_width'], tile_source_type=m['tile_source_type']))
                ProjectStack.objects.get_or_create(
                    project=project_object,
                    stack=stack)
            projects[project_title]['project_object'] = project_object
            # Add permission to the anonymous user to browse project
            assign_perm('can_browse', anon_user, project_object)

        
