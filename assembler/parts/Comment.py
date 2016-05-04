from parts.Part import Part


class Comment(Part):
    def in_output(self):
        return False

    def get_bytes(self):
        return None