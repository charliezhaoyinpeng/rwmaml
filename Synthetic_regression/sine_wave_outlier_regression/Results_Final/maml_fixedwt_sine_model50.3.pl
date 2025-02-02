��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1399538350240qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1399538352064qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1399538350048qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1399538351104q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1399538350336q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1399538350432q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1399538350048qX   1399538350240qX   1399538350336qX   1399538350432qX   1399538351104qX   1399538352064qe.@      ^�=��r=�+����<�<����<��"=t�!���7����=�I}=�y��ޮ���U1�
ꔽ��ƽ�;��׌<h�.�#1=�E=8�P�=0�w�~kʽ@��<��=�������$	����<�}��5;������½�U�=����n��������=%��>f�����w�����>�7�=U��Ț����>�� �zIо�N����e�$�>LN�>��3���d?r���Ӈ%�"�P�!��*U��v�5=^Wh���9���[��3c?U��Go����~l4�����K_��*Ͼʄ�>c�;�?��>��?��?\]=�j7��FT�U��>Vhq��r���,�l�нͻ>|�$��>2�ר���.�,M��C�%>y��� ����>>�'�,���=�A�����QY����þe�1���__�?�+�<�@P�����c�^D#��ý��x��Z$?"gD�ID)?����Y�qȑ�=:
=�����Q�W|S�DED�u���t�'�8>���>��D��j￙�½B�x>��=����m�L���:E�D��&���������*>��ƿZa�wa�&��>�y�v\>��E;,�,�q]:B���	ϔ=���grB�#�>Q|�>c/�>��z�|#��5�����k:=�����=�\��Xs?/&��o="�.�Bӷ=�Yؾ����S#N�ʰM>�1?�`л�a=U�=�J9�����羆}ž����%��=6�?�#S����=�1[��zE���'�sƜ>�ܧ��;�>0_��}D?p�u��]�}�(��� �1�?{7<��e>���K���M��r{�?������>�TB��##�xe���&�������>����e��2�Y��}�Z,=bR���m�RTѿ�n?(�ҿ��ɾ�R�>�)���ܻ�:��k��{'B�W{߾� ?���E�>fĺ>CU��;>��&?�Z��$�CNi>���<�Y�'��=6bk<�z<��/�8�t����=�H����>%��y�������3���Y�^�o�����ȱ�>�}��x�� �ֿ�����?��
�>[�辻�W�N
?�0����@���%�=��&�=��>oFT>�E��A	�4\?��>��R�)��S�>�����s���8�>�R
�I>�>^,Q��]��.�>苳���H�v�?D�g�w�7��	�ȋ������%寽�k?�惿r'����Q"?h���&���#���>_L��_����M=���>kA �̜=wN�dS���	(��)�>&�=�Zտ�sL�`��;�wV�_�x?";*���*�[=\��~����+>��j�`���	���\��ӿ��a������?���.��Ȁ>oa����@��&,�>It>�*��LĿ8�ܿa�>s���ؾ�Կ���>�8C=�J�d����ͽ�"���������W�� ��ϛ��I@��׾�i�\Y+�ۂZ��c_>9�4��\��J�Nx��!"(�����<��p>�6>Cu,=�C��� ������8��_�H&#���%�%���tE������$>M�Ͽq�J�<4*>>`����=$�*>F� �������;�2�����<�q�f�L?ԩ�%t�=�8R>��+�������� 꾐��=(��>�0-=>���>^!�0q��"����}�`�v�ph?�5.:?��\=�@\=�ܾl�i�_>��T>��%�����+fA�M?࿣����<��+������=@P��`�p� �����S�?2m�M�� )I��ͨ��:���8���@�U�5��J�>V��;�<��:�m>�����*�/8���a �n#���3�:0¿#!W=���=����`��n���?;?i���M&������?�<�=���>[F���ٙ=�2ؽ7����k����G=�\	��і��21�8;���KY�g�<��*<��l�E��ٌ���nc�=���y��e�� �{�
P��m= ��;z��#�]���.����s;�Tq�������7ƽ[Ų��@I��ts�;���νϪ@�$T�DCS=^ە=��$<��� >�K%�pԤ�`3?=�<��4�~�@<��<��=�R�'��=�k�<^�P
�<s꿼M���E��qѽQ@�=�	��߽�첽�⽳a�<�D3�0�r=��ؽ�(���=���<��3��'(���=��=&�H�Ǒ��%d�Ǩ�Dj�>����>�=����z��?����h����a7�zt����=K����ʾ���޾m�ܼG��>/c���M5>�*�>��&)E�#?���>�L�����?:;�c�:��>�å�i�>@�4>�')?]���/>����
=ٚ�>U- >�	ɿT,���A�8����=�>��4��o��J���䳾W�;�ü<
����-���?����?�O��ξ�G��}>荭=u�}=����9J�'T3���>@S	��'ˁ�
~O���;�ǐ��LW��>�@�{�����p��'0����>�si��%ս�4�I �^��%>�b��6U��oW�H�g��S]>�PY����=��s���z��4o��=�U<e��vνx|�2Q<����:{o��e6��K����<��~���ɽ^W��P��������R<�g<���*Ӿ��������j!�g�=�غ�Ҳ�>B�ᾉ湽�Ć=�?���5� W��q�=�f���Y�=\��>]��>�嫾R�r��M�>9e�>;{ �L�=�n���/��V[J=�̿�5 �!�����>�-`>n��>��s����>e���=�e��l�T=O�>�+?>I��>eAF�$�a�B�0��(�ea=^� ��qF���7;#n���_)D��>}鳼x3��׻ >�V��=�dٻB �=��=�s�=h��ԇ��䃽�K���ͽ���>X;�w�4��,<p陽iU�=����(=tt4=d�D=��-������=n���>@���6x?4�>�iQ�D�P�41=�3+=!ϐ=��O���C��{W?�����~'���z1���2M�#M2?��H��C7��'��|P�P}�<B�ʾ�C?ha�������o�>4��i�ƿ%ѿ�"L�w���5޾�ʴ�4�� w�>.���f��s�hXҾ�{��3U>G��Ș��� �����=V�k�Ka�?EK����f���Ʒ��ֽ�|H�\�D>�-�vY�� t�����ht=��x��Ͽ���=�8h�n�J�ݟ�������9ᾘ2%>�>>��C���ʾz������rɿu@Լ1�?�%�d�B��=8�X��<.�)�NzU��彀�h=z&���£�O^�>u(1�(�ýf @�K��B�V�#����b�K�콠Lb��a��y�8�a=C岽$#1=�����׽9[㽐V�gi�Yp�;�@�=ýBs�<|ŷ<?�D����O=GL��l����F�08o<�� >pM;?9��	Rʾ�lu>��<{�E�,#��$��#� �@<?>����}�>x���=�@��9M�>6�>�����=�Y]�<!$�X��>,z?�tA�=O��2���ô=؇E=$w>E��1<�=k�9�c��>��;��#M>���q
��v-����s>�G���,=x�$=O���Ϊs<P��<��-��`=)�����ּ#�!>�?�=��&�p�������Z�=��=L`�����>2��|�=�\��|,�<��#>d���v@�>(>r�λb|�:E�4��a�;�˽�u�%W��~ ��6^><q>�o�ߛw���D��a}>>��>�>Ǿ&G����>�0�=�Y��Yg?Frѽ���XU/=�.���S>�=:�T��>�T�s�u^J�/k���l��iȄ�2���puO=t��=��ɾ�E?��񺿁Ҝ�"�	���>�����Ӿ+q�=:�0��B��K�`>����ս�?����<���>���=j���b�f�t�x��>Z^L>ݰ?�P��ѽ�񏾖h���m����.��O��(����۾!OҾ���L� >�>JvV��B>�L��S�ξ>���O�U�VP]�"�v��׏�c�����gW��be���A?�!�9?Fx?�&�=H|>�+"?�����3���>lJt=v���;ꪾ):�=���﻿>���e ?��ھ/�>�᯾fȦ�����7ͼ�o����c>�����g!�>�~4�~譾���!�V����S?6�;r����3,=�)n�Խ�=�0v��=�=Mp�=F!7��"��{Ů�"w�=u��=5���=��_�=K�=���<9LB��V�<�C�)JýV�r�>�=�=� ����ے�=�(���<���v-�����y�+�l<�B�=���<���<��!�z��։н3�Ž�	���_3��9!=�7�9@�b����8J�S-��3����X �=��c#��`<
=Ѝ��^??<,�=h#������B�?���vڿNlҽ��:����>�.��潜�/=bN���VY� zF��ƚ��ݾ=;)�=�0>Jp���JX��'D����=Kg����:�E������@*��I~?��f>�F�>��a�ٓs=	����k��6v��C\>�q��6H=�9>��Q��nſ2Gb��c����/0�fz�{��>�]�����p�����$~ �h����ٿ�������=&�o�8�Tz)�d7�-����l����$�����g	��Vx?�7?i_$?�=����>�+?�;��=��3�>��\�=:���6v;?jO�0Q�>py��)��=��=�}:>� O��㖿��پ?&��S�`�x��>��>E��=�8�>��p��4Y�Id���������:�=��[�\�־m"���=����\��>X��?F1�>�2�>t≾3b?�9�<:��>h�辯����R�E���RT?x��>=�n>��W�_<U��N�=�QT�R�>N����=���>P�{�C��ڮ�E������>?�9��>15.?���=�X�>� '�3x?�T�=]���� �=͏?3%=,�ڿ���>���=�p���͉=��~��y7��(���#�<:����<b��{���顽W4�
xL��O�=n��5�ֽ*�?�ޟ����$���Y;�Bw&>�ս���<�	���c�=^/9��-=鈂�ז��u5���I;��T;�O�v���z
�.��fi۽�I+���=��b��Kb�ߪ��7<>o���u!>;���D�F?XZ��l�=���z<k�-��nا�H%½���>�m��&2>��e�l�����1���|/���>��y>���?�T�ȱ�=�ҿc9>^����>�V�?�ž�#?r�ǾY�D=�~Z�G=��~�>�fƽv��������A�=�����>:�����A�('�>��خ^> )���� �ΩY=i�>���=6Z+���������	�j���;���>!14�����i�=>���=�I>$1��ڦ	�T�⽙0��꘾�K�ߞ�>���>\��OoҿsGǾC�L�;��=�v�=7`���<�<o��������<�Ƚ��,���#`8�@'b=��$���꽚��=����h=��=���=�e$�tQ����=.F���%ֽ�-|�q#����G�&�)��<�j�����=1 ���k�$��P�n�cq�𷜽�^��j�>��%�G =�.b��Ie���?<`�?=h�J7>��B������
J=�"0�:[G�˓=(,;��E������_ƽ�+�;'�����ͽq/��L����������<�0�%ب��F�rTQ��k�9�<O����;��&�p�d��(㿽�`�=��b��l,��ç��6Hھ������=��������?t����C�+t����3��2=��0�#�<x�ξ`.9>ľh>Ƃ(��Y_=""�á��<S$T�(�C�8!h�i�,�����]�'���X�Xp>s�t�E����E=��9[?U�#���c��(��i��>@\?�J�<�(��e�	?0�T� ѿF��f\?�7S�l?�|��:�>���>�������<�@�� ;Gl���ԫ�� �x]�>q��T�)���>G=1>.���֫>֏���$>�zq�ݣ?���5?n��=_HB�o�?���>z���QX�=6��>��<���<f�>��Fb���?�)J��bl>R��>-F�"�>B�M�K3�<T��������ս�ϋ>��=��}=V ʼ��^>��>G���z�=�5?��+=�lμ:5A=�v�= 8K=�5@>S�D>�ƀ>+�0>����^���˿���=(       8?����g)�5=&�?
>w��>�aȼ��=i;L�HԽ�нF�?<Q��~�>�u��M[d=>⵾�������C?�x?g!�>�>����ܾ�(�=[f���<�C�`>S�(�iBᾱA𾓆�>�ڏ�q{~��={9N��=���=�0n?(       y-����ھ�dϿg�r��@Ѿ}E��<=?�� ��#�?��ྟI���.?/�\<@sҼ��>����>+'�=\g����>i@���>�)�=�ZJ��dm��?�C>�?(ţ<�Ĩ?��,�Sd?�I-?�|c>������=���
>S�=K8�>K�&���=       ��
�(       9�^;q]�>F �=���>�A��8l
�r�W</�>ف���>A�;���>� �=�뽊����i�����9}'>}�ּi��=rs>S����=	m���n>��Ծ���=���1?��?�J<������zʽ�܊�趾U٦� 1�=]�J?-���(       I�^����>�lo>��߿54��f��߿�{=?�> >;�ֿ�!�>�B�=:���b��� ��K-�f��=B��K�	��¾-�i�忠�8���>?���˜��>�s�f房�k�=����⽰����N�X�f=��p>��*?!��>��>��